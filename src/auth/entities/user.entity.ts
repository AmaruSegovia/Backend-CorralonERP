import {
  Entity,
  PrimaryColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  BeforeInsert,
} from 'typeorm';
import { v4 as uuidv4 } from 'uuid';

@Entity('users')
export class User {
  @PrimaryColumn('varchar', { length: 36 })
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  password: string;

  @CreateDateColumn()
  created_at: Date;

  @BeforeInsert()
  generateId() {
    if (!this.id) {
      this.id = uuidv4();
    }
  }
}

@Entity('profiles')
export class Profile {
  @PrimaryColumn('varchar', { length: 36 })
  id: string;

  @Column()
  email: string;

  @Column()
  nombre_completo: string;

  @Column({
    type: 'enum',
    enum: ['admin', 'vendedor', 'deposito', 'contador'],
    default: 'vendedor',
  })
  rol: string;

  @Column({ default: true })
  activo: boolean;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
