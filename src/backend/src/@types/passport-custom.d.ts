declare module 'passport-custom' {
  import { Strategy as PassportStrategy } from 'passport';
  export class Strategy extends PassportStrategy {
    constructor(verify: (req: any, done: (error: any, user?: any) => void) => void);
  }
}
