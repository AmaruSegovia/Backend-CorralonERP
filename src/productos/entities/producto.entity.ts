import {
  Entity,
  PrimaryColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  BeforeInsert,
} from 'typeorm';
import { v4 as uuidv4 } from 'uuid';
import { Categoria } from '../../categorias/entities/categoria.entity';

@Entity('productos')
export class Producto {
  @PrimaryColumn('varchar', { length: 36 })
  id: string;

  @Column({ unique: true })
  codigo: string;

  @Column()
  nombre: string;

  @Column({ type: 'text', nullable: true })
  descripcion: string;

  @Column('varchar', { length: 36, nullable: true })
  categoria_id: string;

  @Column('varchar', { length: 36, nullable: true })
  unidad_medida_id: string;

  @Column('decimal', { precision: 12, scale: 2, default: 0 })
  precio_costo: number;

  @Column('decimal', { precision: 12, scale: 2, default: 0 })
  precio_venta: number;

  @Column('decimal', { precision: 5, scale: 2, default: 21.0 })
  iva: number;

  @Column('decimal', { precision: 10, scale: 2, default: 0 })
  stock_minimo: number;

  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  stock_maximo: number;

  @Column({ default: false })
  usa_serie: boolean;

  @Column({ default: false })
  usa_lote: boolean;

  @Column({ default: true })
  activo: boolean;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @ManyToOne(() => Categoria, { nullable: true })
  @JoinColumn({ name: 'categoria_id' })
  categoria: Categoria;

  @BeforeInsert()
  generateId() {
    if (!this.id) {
      this.id = uuidv4();
    }
  }
}
