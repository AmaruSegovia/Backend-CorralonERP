import { Injectable, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { User, Profile } from './entities/user.entity';
import { LoginDto, RegisterDto } from './dto/auth.dto';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    @InjectRepository(Profile)
    private profilesRepository: Repository<Profile>,
    private jwtService: JwtService,
  ) {}

  async register(registerDto: RegisterDto) {
    const { email, password, nombre_completo, rol } = registerDto;

    // Check if user exists
    const existingUser = await this.usersRepository.findOne({
      where: { email },
    });
    if (existingUser) {
      throw new UnauthorizedException('El email ya está registrado');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const userId = uuidv4();
    const user = this.usersRepository.create({
      id: userId,
      email,
      password: hashedPassword,
    });
    await this.usersRepository.save(user);

    // Create profile
    const profile = this.profilesRepository.create({
      id: userId,
      email,
      nombre_completo,
      rol: rol || 'vendedor',
      activo: true,
    });
    await this.profilesRepository.save(profile);

    // Generate token
    const payload = { sub: userId, email, rol: profile.rol };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: userId,
        email,
        nombre_completo,
        rol: profile.rol,
      },
    };
  }

  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;

    // Find user
    const user = await this.usersRepository.findOne({ where: { email } });
    if (!user) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    // Get profile
    const profile = await this.profilesRepository.findOne({
      where: { id: user.id },
    });

    // Generate token
    const payload = { sub: user.id, email: user.email, rol: profile?.rol };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        email: user.email,
        nombre_completo: profile?.nombre_completo,
        rol: profile?.rol,
      },
    };
  }

  async validateUser(userId: string) {
    const profile = await this.profilesRepository.findOne({
      where: { id: userId },
    });
    return profile;
  }
}
