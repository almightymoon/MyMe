import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { randomUUID } from 'crypto';
import { PrismaService } from '../prisma/prisma.service';

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
    const id = randomUUID();
    const objectKey = `wardrobe/${randomUUID()}`;
    const asset = await this.prisma.asset.create({
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
    });
    return {
      assetId: asset.id,
      objectKey: asset.objectKey,
      uploadStatus: asset.uploadStatus,
      maxBytes: MAX_BYTES,
    };
  }

  async complete(userId: string, assetId: string) {
    const asset = await this.requireOwned(userId, assetId);
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
    return {
      assetId: asset.id,
      mimeType: asset.mimeType,
      byteSize: asset.byteSize,
      objectKey: asset.objectKey,
    };
  }

  async remove(userId: string, assetId: string) {
    const asset = await this.requireOwned(userId, assetId);
    await this.prisma.asset.update({
      where: { id: asset.id },
      data: { deletedAt: new Date(), uploadStatus: 'deletionPending' },
    });
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
