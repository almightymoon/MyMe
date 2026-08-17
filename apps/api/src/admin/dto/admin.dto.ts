import {
  IsBoolean,
  IsEmail,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { Type } from 'class-transformer';

export class AdminLoginDto {
  @IsEmail()
  @MaxLength(180)
  email!: string;

  @IsString()
  @MinLength(12)
  @MaxLength(128)
  password!: string;
}

export class AdminUserListQueryDto {
  @IsOptional()
  @IsString()
  @MaxLength(120)
  q?: string;

  @IsOptional()
  @IsIn(['active', 'disabled', 'deletionPending'])
  status?: 'active' | 'disabled' | 'deletionPending';

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  pageSize?: number;
}

export class PatchUserStatusDto {
  @IsIn(['active', 'disabled'])
  status!: 'active' | 'disabled';
}

export class AssignSubscriptionDto {
  @IsUUID()
  planId!: string;

  @IsOptional()
  @IsIn(['trialing', 'active'])
  status?: 'trialing' | 'active';

  @IsOptional()
  @IsString()
  @MaxLength(500)
  notes?: string;
}

export class PatchSubscriptionDto {
  @IsOptional()
  @IsIn(['trialing', 'active', 'pastDue', 'canceled', 'expired'])
  status?: 'trialing' | 'active' | 'pastDue' | 'canceled' | 'expired';

  @IsOptional()
  @IsString()
  @MaxLength(500)
  notes?: string;
}

export class UpsertPlanDto {
  @IsString()
  @MinLength(2)
  @MaxLength(40)
  code!: string;

  @IsString()
  @MinLength(2)
  @MaxLength(80)
  name!: string;

  @IsIn(['none', 'month', 'year'])
  interval!: 'none' | 'month' | 'year';

  @IsString()
  @MinLength(1)
  @MaxLength(40)
  amountMinor!: string;

  @IsString()
  @MinLength(3)
  @MaxLength(3)
  currencyCode!: string;

  @IsOptional()
  @IsBoolean()
  active?: boolean;
}

export class CreateAdminUserDto {
  @IsEmail()
  @MaxLength(180)
  email!: string;

  @IsString()
  @MinLength(2)
  @MaxLength(80)
  displayName!: string;

  @IsString()
  @MinLength(12)
  @MaxLength(128)
  password!: string;
}

export class AuditListQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  pageSize?: number;
}
