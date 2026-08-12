import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { randomUUID } from 'crypto';
import { PrismaService } from '../prisma/prisma.service';
import {
  createDownloadUrl,
  createUploadUrl,
  deleteObject,
  getObjectStorage,
  objectExists,
} from './object-storage';

const ALLOWED_MIME = new Set(['image/jpeg', 'image/png', 'image/webp']);
const MAX_BYTES = 8 * 1024 * 1024;

@Injectable()
export class AssetsService {
  constructor(private readonly prisma: PrismaService) {}

  async prepareUpload(
    userId: string,
    input: {
      kind: 'wardrobeOriginal' | 'wardrobeThumbnail';
      mimeType: string;
      byteSize: number;
      checksum: string;
      width?: number;
      height?: number;
    },
  ) {
    if (!ALLOWED_MIME.has(input.mimeType)) {
      throw new ForbiddenException({
        code: 'ASSET_MIME_REJECTED',
        message: 'This image type is not allowed.',
      });
    }
    if (input.byteSize <= 0 || input.byteSize > MAX_BYTES) {
      throw new ForbiddenException({
        code: 'ASSET_TOO_LARGE',
        message: 'This image is too large to upload.',
      });
    }
    const storage = this.storageOrThrowInProduction();
    const id = randomUUID();
    const objectKey = `wardrobe/${randomUUID()}`;
    const [asset, uploadUrl] = await Promise.all([
      this.prisma.asset.create({
        data: {
          id,
          userId,
          kind: input.kind,
          objectKey,
          mimeType: input.mimeType,
          byteSize: input.byteSize,
          checksum: input.checksum,
          width: input.width,
          height: input.height,
        },
      }),
      storage
        ? createUploadUrl(
            storage.client,
            storage.config,
            objectKey,
            input.mimeType,
          )
        : Promise.resolve(''),
    ]);
    return {
      assetId: asset.id,
      uploadUrl,
      uploadMethod: 'PUT',
      expiresInSeconds: storage?.config.expiresInSeconds ?? 300,
      headers: {
        'Content-Type': input.mimeType,
      },
      uploadStatus: asset.uploadStatus,
      maxBytes: MAX_BYTES,
    };
  }

  async complete(userId: string, assetId: string) {
    const asset = await this.requireOwned(userId, assetId);
    const storage = this.storageOrThrowInProduction();
    if (storage) {
      const head = await objectExists(
        storage.client,
        storage.config,
        asset.objectKey,
      );
      if (!head.exists) {
        throw new ForbiddenException({
          code: 'ASSET_NOT_UPLOADED',
          message: 'The image was not found in private storage.',
        });
      }
      if (head.contentLength && head.contentLength !== asset.byteSize) {
        throw new ForbiddenException({
          code: 'ASSET_SIZE_MISMATCH',
          message: 'The uploaded image size does not match.',
        });
      }
    }
    return this.prisma.asset.update({
      where: { id: asset.id },
      data: { uploadStatus: 'uploaded' },
    });
  }

  async download(userId: string, assetId: string) {
    const asset = await this.requireOwned(userId, assetId);
    if (asset.uploadStatus !== 'uploaded' || asset.deletedAt) {
      throw new NotFoundException({
        code: 'ASSET_NOT_READY',
        message: 'This image is not available.',
      });
    }
    const storage = this.storageOrThrowInProduction();
    const downloadUrl = storage
      ? await createDownloadUrl(storage.client, storage.config, asset.objectKey)
      : '';
    return {
      assetId: asset.id,
      mimeType: asset.mimeType,
      byteSize: asset.byteSize,
      downloadUrl,
      expiresInSeconds: storage?.config.expiresInSeconds ?? 300,
    };
  }

  async remove(userId: string, assetId: string) {
    const asset = await this.requireOwned(userId, assetId);
    const storage = getObjectStorage();
    if (storage) {
      try {
        await deleteObject(storage.client, storage.config, asset.objectKey);
      } catch {
        await this.prisma.asset.update({
          where: { id: asset.id },
          data: { deletedAt: new Date(), uploadStatus: 'deletionPending' },
        });
        return;
      }
    }
    await this.prisma.asset.update({
      where: { id: asset.id },
      data: { deletedAt: new Date(), uploadStatus: 'deletionPending' },
    });
  }

  private storageOrThrowInProduction() {
    const storage = getObjectStorage();
    if (!storage && process.env.NODE_ENV === 'production') {
      throw new ForbiddenException({
        code: 'ASSET_STORAGE_UNAVAILABLE',
        message: 'Private object storage is not configured.',
      });
    }
    return storage;
  }

  private async requireOwned(userId: string, assetId: string) {
    const asset = await this.prisma.asset.findUnique({
      where: { id: assetId },
    });
    if (!asset || asset.userId !== userId) {
      throw new NotFoundException({
        code: 'ASSET_NOT_FOUND',
        message: 'This image is not available.',
      });
    }
    return asset;
  }
}
