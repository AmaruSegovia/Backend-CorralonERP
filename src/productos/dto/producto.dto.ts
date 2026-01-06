import {
  IsString,
  IsOptional,
  IsNumber,
  IsBoolean,
  Min,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateProductoDto {
  @ApiProperty({ example: 'PROD-001' })
  @IsString()
  codigo: string;

  @ApiProperty({ example: 'Cemento Portland' })
  @IsString()
  nombre: string;

  @ApiPropertyOptional({ example: 'Bolsa de 50kg de cemento' })
  @IsOptional()
  @IsString()
  descripcion?: string;

  @ApiPropertyOptional({ example: 'uuid-categoria' })
  @IsOptional()
  @IsString()
  categoria_id?: string;

  @ApiPropertyOptional({ example: 'uuid-unidad' })
  @IsOptional()
  @IsString()
  unidad_medida_id?: string;

  @ApiPropertyOptional({ example: 500.0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  precio_costo?: number;

  @ApiPropertyOptional({ example: 750.0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  precio_venta?: number;

  @ApiPropertyOptional({ example: 21.0 })
  @IsOptional()
  @IsNumber()
  iva?: number;

  @ApiPropertyOptional({ example: 10 })
  @IsOptional()
  @IsNumber()
  stock_minimo?: number;

  @ApiPropertyOptional({ example: 100 })
  @IsOptional()
  @IsNumber()
  stock_maximo?: number;

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean()
  usa_serie?: boolean;

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean()
  usa_lote?: boolean;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  activo?: boolean;
}

export class UpdateProductoDto {
  @ApiPropertyOptional({ example: 'PROD-001' })
  @IsOptional()
  @IsString()
  codigo?: string;

  @ApiPropertyOptional({ example: 'Cemento Portland Modificado' })
  @IsOptional()
  @IsString()
  nombre?: string;

  @ApiPropertyOptional({ example: 'Descripción actualizada' })
  @IsOptional()
  @IsString()
  descripcion?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  categoria_id?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  unidad_medida_id?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  @Min(0)
  precio_costo?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  @Min(0)
  precio_venta?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  iva?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  stock_minimo?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  stock_maximo?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  usa_serie?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  usa_lote?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  activo?: boolean;
}
