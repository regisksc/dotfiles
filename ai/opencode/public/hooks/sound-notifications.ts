#!/usr/bin/env node
/**
 * OpenCode Sound Notifications
 * 
 * Plays macOS system sounds for key LLM session events.
 * Attach these hooks in your ~/.config/opencode/opencode.json
 * 
 * Hook Events:
 * - tool.execute.before (permission needed) → Glass sound
 * - tool.execute.after (task complete) → Hero sound  
 * - session start → Submarine sound
 * - error → Ping sound
 * 
 * Usage: Add to opencode.json hooks section
 */

import { execSync } from 'node:child_process';
import { existsSync } from 'node:fs';

const SOUNDS = {
  Hero: '/System/Library/Sounds/Hero.aiff',
  Glass: '/System/Library/Sounds/Glass.aiff',
  Ping: '/System/Library/Sounds/Ping.aiff',
  Submarine: '/System/Library/Sounds/Submarine.aiff',
  Funk: '/System/Library/Sounds/Funk.aiff',
};

function playSound(soundName: keyof typeof SOUNDS): void {
  const soundPath = SOUNDS[soundName];
  if (!existsSync(soundPath)) return;
  
  try {
    execSync(`afplay "${soundPath}"`, { stdio: 'ignore' });
  } catch {
    // Silent failure - don't break workflow
  }
}

function notify(title: string, message: string): void {
  try {
    execSync(`osascript -e 'display notification "${message}" with title "${title}"'`, { stdio: 'ignore' });
  } catch {
    // Silent failure
  }
}

// Export hook handlers for OpenCode plugin system
export default async function (context: { directory: string }) {
  return {
    // Called before tool execution - permission may be needed
    'tool.execute.before': async (input: { tool_name?: string; tool_input?: Record<string, unknown> }) => {
      // Play subtle sound for permission-requiring actions
      playSound('Glass');
      notify('OpenCode', `Tool requires attention: ${input.tool_name || 'unknown'}`);
    },

    // Called after tool completes
    'tool.execute.after': async (input: { 
      tool_name?: string; 
      tool_output?: string;
      is_error?: boolean;
    }) => {
      if (input.is_error) {
        playSound('Ping');
        notify('OpenCode', `Tool failed: ${input.tool_name}`);
      } else {
        playSound('Hero');
        notify('OpenCode', `Task completed: ${input.tool_name}`);
      }
    },

    // Called when session ends (Stop event equivalent)
    'session.end': async () => {
      playSound('Hero');
      notify('OpenCode', 'Session complete');
    },
  };
}
