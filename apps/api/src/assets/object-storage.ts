import {
  DeleteObjectCommand,
  GetObjectCommand,
  HeadObjectCommand,
  PutObjectCommand,
  S3Client,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

export type ObjectStorageConfig = {
  endpoint: string;
  region: string;
  bucket: string;
  accessKey: string;
  secretKey: string;
  expiresInSeconds: number;
};

export function readObjectStorageConfig(): ObjectStorageConfig | null {
  const endpoint = process.env.OBJECT_STORAGE_ENDPOINT;
  const accessKey = process.env.OBJECT_STORAGE_ACCESS_KEY;
  const secretKey = process.env.OBJECT_STORAGE_SECRET_KEY;
  const bucket = process.env.OBJECT_STORAGE_BUCKET;
  if (!endpoint || !accessKey || !secretKey || !bucket) return null;
  return {
    endpoint,
    region: process.env.OBJECT_STORAGE_REGION || 'us-east-1',
    bucket,
    accessKey,
    secretKey,
    expiresInSeconds: Number(
      process.env.OBJECT_STORAGE_SIGNED_URL_SECONDS ?? 300,
    ),
  };
}

export function createObjectStorageClient(
  config: ObjectStorageConfig,
): S3Client {
  return new S3Client({
    region: config.region,
    endpoint: config.endpoint,
    forcePathStyle: true,
    credentials: {
      accessKeyId: config.accessKey,
      secretAccessKey: config.secretKey,
    },
  });
}

let cachedStorage: {
  key: string;
  client: S3Client;
  config: ObjectStorageConfig;
} | null = null;

export function getObjectStorage(): {
  client: S3Client;
  config: ObjectStorageConfig;
} | null {
  const config = readObjectStorageConfig();
  if (!config) return null;
  const key = `${config.endpoint}|${config.region}|${config.bucket}|${config.accessKey}`;
  if (!cachedStorage || cachedStorage.key !== key) {
    cachedStorage = {
      key,
      client: createObjectStorageClient(config),
      config,
    };
  }
  return { client: cachedStorage.client, config: cachedStorage.config };
}

export async function createUploadUrl(
  client: S3Client,
  config: ObjectStorageConfig,
  objectKey: string,
  mimeType: string,
): Promise<string> {
  return getSignedUrl(
    client,
    new PutObjectCommand({
      Bucket: config.bucket,
      Key: objectKey,
      ContentType: mimeType,
    }),
    { expiresIn: config.expiresInSeconds },
  );
}

export async function createDownloadUrl(
  client: S3Client,
  config: ObjectStorageConfig,
  objectKey: string,
): Promise<string> {
  return getSignedUrl(
    client,
    new GetObjectCommand({
      Bucket: config.bucket,
      Key: objectKey,
    }),
    { expiresIn: config.expiresInSeconds },
  );
}

export async function objectExists(
  client: S3Client,
  config: ObjectStorageConfig,
  objectKey: string,
): Promise<{ exists: boolean; contentLength?: number }> {
  try {
    const head = await client.send(
      new HeadObjectCommand({
        Bucket: config.bucket,
        Key: objectKey,
      }),
    );
    return { exists: true, contentLength: head.ContentLength };
  } catch {
    return { exists: false };
  }
}

export async function deleteObject(
  client: S3Client,
  config: ObjectStorageConfig,
  objectKey: string,
): Promise<void> {
  await client.send(
    new DeleteObjectCommand({
      Bucket: config.bucket,
      Key: objectKey,
    }),
  );
}
