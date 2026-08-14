import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import {
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
  MinLength,
} from 'class-validator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { RequestUser } from '../auth/types/request-user';
import { AssetsService } from './assets.service';

class PrepareUploadDto {
  @IsIn(['wardrobeOriginal', 'wardrobeThumbnail'])
  kind!: 'wardrobeOriginal' | 'wardrobeThumbnail';

  @IsString()
  mimeType!: string;

  @IsInt()
  @Min(1)
  @Max(8 * 1024 * 1024)
  byteSize!: number;

  @IsString()
  @MinLength(32)
  checksum!: string;

  @IsOptional()
  @IsInt()
  width?: number;

  @IsOptional()
  @IsInt()
  height?: number;
}

@ApiTags('assets')
@ApiBearerAuth('access-token')
@Controller('assets')
export class AssetsController {
  constructor(private readonly assets: AssetsService) {}

  @Post('prepare-upload')
  @ApiOperation({ summary: 'Authorize a private wardrobe image upload' })
  prepare(@CurrentUser() user: RequestUser, @Body() body: PrepareUploadDto) {
    return this.assets.prepareUpload(user.id, body);
  }

  @Post(':id/complete')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Confirm an object-storage upload finished' })
  complete(
    @CurrentUser() user: RequestUser,
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
  ) {
    return this.assets.complete(user.id, id);
  }

  @Get(':id/download')
  @ApiOperation({ summary: 'Issue an authenticated download description' })
  download(
    @CurrentUser() user: RequestUser,
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
  ) {
    return this.assets.download(user.id, id);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a private wardrobe asset' })
  remove(
    @CurrentUser() user: RequestUser,
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
  ) {
    return this.assets.remove(user.id, id);
  }
}
