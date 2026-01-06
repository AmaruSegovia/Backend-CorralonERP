import { IsString, IsOptional, IsBoolean } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateCategoriaDto {
  @ApiProperty({ example: 'Cemento y Adhesivos' })
  @IsString()
  nombre: string;

  @ApiPropertyOptional({ example: 'Cementos, pegamentos y adhesivos' })
  @IsOptional()
  @IsString()
  descripcion?: string;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  activo?: boolean;
}

export class UpdateCategoriaDto extends CreateCategoriaDto {}
