import {
  Entity,
  PrimaryColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  BeforeInsert,
} from 'typeorm';
import { v4 as uuidv4 } from 'uuid';

@Entity('clientes')
export class Cliente {
  @PrimaryColumn('varchar', { length: 36 })
  id: string;

  @Column({
    type: 'enum',
    enum: ['fisica', 'juridica'],
    nullable: true,
  })
  tipo_persona: string;

  @Column()
  razon_social: string;

  @Column({ nullable: true })
  nombre_fantasia: string;

  @Column({ unique: true, nullable: true })
  cuit_cuil: string;

  @Column({
    type: 'enum',
    enum: [
      'responsable_inscripto',
      'monotributista',
      'exento',
      'consumidor_final',
    ],
    nullable: true,
  })
  condicion_iva: string;

  @Column({ nullable: true })
  email: string;

  @Column({ nullable: true })
  telefono: string;

  @Column({ type: 'text', nullable: true })
  direccion: string;

  @Column({ nullable: true })
  ciudad: string;

  @Column({ default: 'Jujuy' })
  provincia: string;

  @Column({ nullable: true })
  codigo_postal: string;

  @Column('decimal', { precision: 12, scale: 2, default: 0 })
  limite_credito: number;

  @Column({ default: 0 })
  dias_credito: number;

  @Column('varchar', { length: 36, nullable: true })
  lista_precio_id: string;

  @Column({ nullable: true })
  arquitecto_obra: string;

  @Column({ type: 'text', nullable: true })
  observaciones: string;

  @Column({ default: true })
  activo: boolean;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @BeforeInsert()
  generateId() {
    if (!this.id) {
      this.id = uuidv4();
    }
  }
}
