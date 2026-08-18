import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  IsEmail,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
  ValidateNested,
} from 'class-validator';

export class DeviceInfoDto {
  @ApiProperty()
  @IsString()
  @MinLength(8)
  @MaxLength(128)
  clientGeneratedDeviceId!: string;

  @ApiProperty({ example: 'ios' })
  @IsString()
  @MaxLength(32)
  platform!: string;

  @ApiProperty({ example: '1.0.0' })
  @IsString()
  @MaxLength(32)
  appVersion!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(80)
  deviceLabel?: string;
}

export class GoogleSignInDto {
  @ApiProperty()
  @IsString()
  @MinLength(20)
  @MaxLength(8192)
  idToken!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(256)
  nonce?: string;

  @ApiProperty({ type: DeviceInfoDto })
  @ValidateNested()
  @Type(() => DeviceInfoDto)
  device!: DeviceInfoDto;
}

export class AppleSignInDto {
  @ApiProperty()
  @IsString()
  @MinLength(20)
  @MaxLength(8192)
  identityToken!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(256)
  nonce?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(120)
  givenName?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(120)
  familyName?: string;

  @ApiProperty({ type: DeviceInfoDto })
  @ValidateNested()
  @Type(() => DeviceInfoDto)
  device!: DeviceInfoDto;
}

export class RefreshDto {
  @ApiProperty()
  @IsString()
  @MinLength(16)
  @MaxLength(512)
  refreshToken!: string;

  @ApiProperty({ type: DeviceInfoDto })
  @ValidateNested()
  @Type(() => DeviceInfoDto)
  device!: DeviceInfoDto;
}

export class LogoutDto {
  @ApiProperty()
  @IsString()
  @MinLength(16)
  @MaxLength(512)
  refreshToken!: string;
}

export class DeleteAccountDto {
  @ApiProperty({ example: 'DELETE MY ACCOUNT' })
  @IsString()
  confirmation!: string;
}

export class EmailSignInDto {
  @ApiProperty({ example: 'ada@example.com' })
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim().toLowerCase() : value,
  )
  @IsEmail()
  @MaxLength(254)
  email!: string;

  @ApiProperty()
  @IsString()
  @MinLength(8)
  @MaxLength(128)
  password!: string;

  @ApiProperty({ type: DeviceInfoDto })
  @ValidateNested()
  @Type(() => DeviceInfoDto)
  device!: DeviceInfoDto;
}

export class EmailRegisterDto extends EmailSignInDto {
  @ApiPropertyOptional()
  @IsOptional()
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString()
  @MaxLength(80)
  displayName?: string;
}

export class DeviceIdParamDto {
  @IsUUID()
  deviceId!: string;
}
