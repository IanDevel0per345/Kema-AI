/**
 * TERMUX PROOT-DISTRO PROVIDER (Local Sandbox)
 * 
 * Este arquivo cria um provedor local que simula a mesma arquitetura do Daytona
 * ou Platinum, mas rodando as VMs usando `proot-distro` diretamente no Termux.
 */

import { exec } from 'node:child_process';
import { promisify } from 'node:util';
import { config } from '../../config';

const execAsync = promisify(exec);

export interface SandboxState {
  id: string;
  status: 'running' | 'stopped' | 'creating' | 'error';
  proxyUrl?: string;
  createdAt: string;
}

export class TermuxProotProvider {
  /**
   * Cria uma nova "VM" clonando o ubuntu base do proot-distro.
   */
  async createSandbox(id: string, env: Record<string, string> = {}): Promise<SandboxState> {
    console.log(`[TermuxProvider] Criando VM para o projeto ${id}...`);
    
    // Na arquitetura Termux, criamos uma instalação nova do ubuntu para isolar os arquivos
    const distroName = `ubuntu_${id.replace(/-/g, '_')}`;
    
    try {
      // Clona/instala o ubuntu para este projeto específico
      await execAsync(`proot-distro install ${distroName} --override-alias ubuntu`);
      
      return {
        id,
        status: 'running',
        proxyUrl: `http://localhost:8000`, // A porta local onde o opencode-rest vai subir na VM
        createdAt: new Date().toISOString(),
      };
    } catch (e) {
      console.error(`[TermuxProvider] Falha ao criar a distro ${distroName}:`, e);
      throw new Error(`Falha ao provisionar VM Local: ${e}`);
    }
  }

  /**
   * Executa um comando dentro da VM usando proot-distro login
   */
  async execCommand(id: string, command: string): Promise<{ stdout: string; stderr: string }> {
    const distroName = `ubuntu_${id.replace(/-/g, '_')}`;
    console.log(`[TermuxProvider] Rodando comando em ${distroName}: ${command}`);
    
    try {
      // Roda o comando dentro da "VM" perfeitamente isolada
      const { stdout, stderr } = await execAsync(`proot-distro login ${distroName} -- bash -c "${command}"`);
      return { stdout, stderr };
    } catch (e: any) {
      return { stdout: e.stdout || '', stderr: e.stderr || String(e) };
    }
  }

  /**
   * Hiberna a VM por inatividade (Suspende processos, economiza RAM)
   */
  async sleepSandbox(id: string): Promise<void> {
    const distroName = `ubuntu_${id.replace(/-/g, '_')}`;
    console.log(`[TermuxProvider] Suspendendo a VM ${distroName} por inatividade (Economizando RAM)...`);
    
    // Mata todos os processos rodando dentro desse proot-distro
    // (Os arquivos continuam salvos no disco do Android)
    await execAsync(`pkill -f "proot.*${distroName}" || true`);
  }

  /**
   * Deleta a VM (Limpa os arquivos)
   */
  async destroySandbox(id: string): Promise<void> {
    const distroName = `ubuntu_${id.replace(/-/g, '_')}`;
    console.log(`[TermuxProvider] Destruindo a VM ${distroName}...`);
    await execAsync(`proot-distro remove ${distroName} || true`);
  }
}

export const termuxProvider = new TermuxProotProvider();
