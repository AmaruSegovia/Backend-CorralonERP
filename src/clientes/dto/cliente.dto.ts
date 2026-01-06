import {
  IsString,
  IsOptional,
  IsNumber,
  IsBoolean,
  IsEmail,
  Min,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateClienteDto {
  @ApiProperty({ example: 'fisica', enum: ['fisica', 'juridica'] })
  @IsOptional()
  @IsString()
  tipo_persona?: string;

  @ApiProperty({ example: 'Juan Pérez' })
  @IsString()
  razon_social: string;

  @ApiPropertyOptional({ example: 'Ferretería El Sol' })
  @IsOptional()
  @IsString()
  nombre_fantasia?: string;

  @ApiPropertyOptional({ example: '20-12345678-9' })
  @IsOptional()
  @IsString()
  cuit_cuil?: string;

  @ApiPropertyOptional({ example: 'responsable_inscripto' })
  @IsOptional()
  @IsString()
  condicion_iva?: string;

  @ApiPropertyOptional({ example: 'cliente@email.com' })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiPropertyOptional({ example: '388-1234567' })
  @IsOptional()
  @IsString()
  telefono?: string;

  @ApiPropertyOptional({ example: 'Av. Principal 123' })
  @IsOptional()
  @IsString()
  direccion?: string;

  @ApiPropertyOptional({ example: 'San Salvador de Jujuy' })
  @IsOptional()
  @IsString()
  ciudad?: string;

  @ApiPropertyOptional({ example: 'Jujuy' })
  @IsOptional()
  @IsString()
  provincia?: string;

  @ApiPropertyOptional({ example: '4600' })
  @IsOptional()
  @IsString()
  codigo_postal?: string;

  @ApiPropertyOptional({ example: 50000 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  limite_credito?: number;

  @ApiPropertyOptional({ example: 30 })
  @IsOptional()
  @IsNumber()
  dias_credito?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  lista_precio_id?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  arquitecto_obra?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  observaciones?: string;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  activo?: boolean;
}

export class UpdateClienteDto extends CreateClienteDto {}
