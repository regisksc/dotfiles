#!/usr/bin/env node
// caveman-hook-version: 1.0.0
// Auto-caveman Mode Hook — PrePromptSubmit hook
// Automatically applies caveman mode to all responses with 3 configurable modes
//
// Modes:
// 1. lite - No filler/hedging, keep articles + full sentences
// 2. full - Drop articles, fragments OK, short synonyms (default)
// 3. ultra - Abbreviate, strip conjunctions, arrows for causality
//
// Configuration: Set CAVEMAN_MODE environment variable or create ~/.config/opencode/caveman-config.json

const fs = require('fs');
const path = require('path');

// Default configuration
const DEFAULT_MODE = 'full';
const CONFIG_PATH = path.join(process.env.HOME, '.config', 'opencode', 'caveman-config.json');

// Load configuration
function loadConfig() {
  try {
    if (fs.existsSync(CONFIG_PATH)) {
      const config = JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf8'));
      return config.mode || DEFAULT_MODE;
    }
  } catch (err) {
    console.error('Error loading caveman config:', err.message);
  }
  
  // Check environment variable
  const envMode = process.env.CAVEMAN_MODE;
  if (envMode && ['lite', 'full', 'ultra'].includes(envMode)) {
    return envMode;
  }
  
  return DEFAULT_MODE;
}

// Caveman transformation rules by mode
const CAVEMAN_RULES = {
  lite: {
    remove: [
      // Filler words
      /\b(just|really|basically|actually|simply|of course|certainly|sure|happy to|glad to)\b/gi,
      // Hedging
      /\b(might|maybe|perhaps|possibly|could|would|should)\b(?=\s+(be|have|do|make|take|give))/gi,
      // Pleasanteries
      /\b(Hello|Hi|Hey|Thanks|Thank you|Please|Excuse me|Sorry)\b,\s*/gi,
      // Filler phrases
      /\b(I think|I believe|in my opinion|it seems that|it appears that)\b/gi,
    ],
    keepArticles: true,
    maxWords: 30, // Average sentence length
  },
  
  full: {
    remove: [
      // Everything from lite plus articles
      /\b(just|really|basically|actually|simply|of course|certainly|sure|happy to|glad to)\b/gi,
      /\b(might|maybe|perhaps|possibly|could|would|should)\b(?=\s+(be|have|do|make|take|give))/gi,
      /\b(Hello|Hi|Hey|Thanks|Thank you|Please|Excuse me|Sorry)\b,\s*/gi,
      /\b(I think|I believe|in my opinion|it seems that|it appears that)\b/gi,
      // Articles
      /\b(a|an|the)\s+/gi,
      // Conjunctions
      /\b(and|but|or|yet|so|for|nor)\s+/gi,
      // Prepositions at start
      /^(In|On|At|For|With|By|To|From|About|As)\s+/gi,
    ],
    synonyms: {
      'extensive': 'big',
      'comprehensive': 'full',
      'implementation': 'impl',
      'configuration': 'config',
      'authentication': 'auth',
      'authorization': 'authz',
      'database': 'db',
      'function': 'fn',
      'application': 'app',
      'documentation': 'docs',
      'repository': 'repo',
      'synchronization': 'sync',
      'optimization': 'opt',
      'performance': 'perf',
    },
    keepArticles: false,
    maxWords: 20,
  },
  
  ultra: {
    remove: [
      // Everything from full
      /\b(just|really|basically|actually|simply|of course|certainly|sure|happy to|glad to)\b/gi,
      /\b(might|maybe|perhaps|possibly|could|would|should)\b(?=\s+(be|have|do|make|take|give))/gi,
      /\b(Hello|Hi|Hey|Thanks|Thank you|Please|Excuse me|Sorry)\b,\s*/gi,
      /\b(I think|I believe|in my opinion|it seems that|it appears that)\b/gi,
      /\b(a|an|the)\s+/gi,
      /\b(and|but|or|yet|so|for|nor)\s+/gi,
      /^(In|On|At|For|With|By|To|From|About|As)\s+/gi,
      // More conjunctions
      /\b(because|since|although|while|if|unless|until|when|where|why)\s+/gi,
      // Adverbs
      /\b(very|quite|rather|somewhat|fairly|pretty|extremely|incredibly|totally|completely)\s+/gi,
    ],
    synonyms: {
      'extensive': 'big',
      'comprehensive': 'full',
      'implementation': 'impl',
      'configuration': 'config',
      'authentication': 'auth',
      'authorization': 'authz',
      'database': 'db',
      'function': 'fn',
      'application': 'app',
      'documentation': 'docs',
      'repository': 'repo',
      'synchronization': 'sync',
      'optimization': 'opt',
      'performance': 'perf',
      'requires': 'needs',
      'necessary': 'needed',
      'important': 'key',
      'essential': 'key',
      'fundamental': 'core',
      'primary': 'main',
      'secondary': 'second',
      'tertiary': 'third',
      'initialize': 'init',
      'terminate': 'stop',
      'execute': 'run',
      'implement': 'do',
      'create': 'make',
      'modify': 'change',
      'delete': 'del',
      'validate': 'check',
      'verify': 'check',
    },
    abbreviations: {
      'for example': 'eg',
      'that is': 'ie',
      'et cetera': 'etc',
      'versus': 'vs',
      'with': 'w/',
      'without': 'w/o',
      'reference': 'ref',
      'maximum': 'max',
      'minimum': 'min',
      'average': 'avg',
      'standard deviation': 'stddev',
      'approximately': '≈',
      'therefore': '∴',
      'because': '∵',
      'leads to': '→',
      'results in': '→',
      'causes': '→',
    },
    keepArticles: false,
    maxWords: 15,
  },
};

// Apply caveman transformation
function applyCaveman(text, mode) {
  const rules = CAVEMAN_RULES[mode];
  if (!rules) return text;
  
  let result = text;
  
  // Apply removals
  rules.remove.forEach(regex => {
    result = result.replace(regex, '');
  });
  
  // Apply synonyms
  if (rules.synonyms) {
    Object.entries(rules.synonyms).forEach(([from, to]) => {
      const regex = new RegExp(`\\b${from}\\b`, 'gi');
      result = result.replace(regex, to);
    });
  }
  
  // Apply abbreviations (ultra mode only)
  if (rules.abbreviations) {
    Object.entries(rules.abbreviations).forEach(([from, to]) => {
      const regex = new RegExp(from, 'gi');
      result = result.replace(regex, to);
    });
  }
  
  // Clean up extra spaces
  result = result
    .replace(/\s+/g, ' ')
    .replace(/\s+([.,;:!?])/g, '$1')
    .replace(/([.,;:!?])\s+/g, '$1 ')
    .trim();
  
  // Split into sentences and apply max words
  const sentences = result.split(/[.!?]+/).filter(s => s.trim());
  const processedSentences = sentences.map(sentence => {
    const words = sentence.trim().split(/\s+/);
    if (words.length > rules.maxWords) {
      // Keep first N words
      return words.slice(0, rules.maxWords).join(' ') + '...';
    }
    return sentence.trim();
  });
  
  return processedSentences.join('. ') + (result.endsWith('.') ? '' : '.');
}

// Main hook function
function main() {
  const stdin = fs.readFileSync(0, 'utf8');
  let event;
  
  try {
    event = JSON.parse(stdin);
  } catch (err) {
    console.error('Error parsing stdin:', err.message);
    process.exit(1);
  }
  
  // Only process PrePromptSubmit events
  if (event.event !== 'PrePromptSubmit') {
    // Pass through unchanged
    console.log(JSON.stringify(event));
    return;
  }
  
  const cavemanMode = loadConfig();
  
  // Check if user explicitly disabled caveman
  const userPrompt = event.data.userPrompt?.toLowerCase() || '';
  if (userPrompt.includes('stop caveman') || 
      userPrompt.includes('normal mode') ||
      userPrompt.includes('disable caveman')) {
    // Pass through unchanged
    console.log(JSON.stringify(event));
    return;
  }
  
  // Check if user wants to change mode
  const modeMatch = userPrompt.match(/caveman\s+(lite|full|ultra)/i);
  if (modeMatch) {
    const newMode = modeMatch[1].toLowerCase();
    if (newMode !== cavemanMode) {
      // Update config
      try {
        fs.writeFileSync(CONFIG_PATH, JSON.stringify({ mode: newMode }, null, 2));
        console.log(JSON.stringify({
          ...event,
          data: {
            ...event.data,
            systemPromptAddition: `\n[CAVEMAN MODE CHANGED TO: ${newMode.toUpperCase()}]\n`
          }
        }));
        return;
      } catch (err) {
        console.error('Error saving caveman config:', err.message);
      }
    }
  }
  
  // Add caveman instruction to system prompt
  
            if (userPrompt.includes('is caveman on') || userPrompt.includes('caveman status')) {
                textPart.text += `\n[SYSTEM STATUS INTERCEPT: Tell the user "Yes, Caveman ${cavemanMode.toUpperCase()} is currently active and intercepting prompts via hook." Do not search tools.]\n`;
                return;
            }
            const cavemanInstruction = `\n[COMMUNICATE IN CAVEMAN MODE: ${cavemanMode.toUpperCase()}]\n` +
    `Rules: Drop filler words (just/really/basically). ` +
    `Keep technical accuracy. Use short sentences. ` +
    `Code blocks unchanged. Be concise.\n`;
  
  const updatedEvent = {
    ...event,
    data: {
      ...event.data,
      systemPromptAddition: (event.data.systemPromptAddition || '') + cavemanInstruction
    }
  };
  
  console.log(JSON.stringify(updatedEvent));
}

if (require.main === module) {
  main();
}
module.exports = {
  CavemanPlugin: async () => {
    return {
      'experimental.chat.messages.transform': async (_input, output) => {
        const cavemanMode = loadConfig();
        const messages = output.messages || [];
        
        // Check for user command to disable/enable caveman
        for (let i = messages.length - 1; i >= 0; i--) {
            const entry = messages[i];
            if (!entry || entry.info?.role !== 'user') continue;
            
            const textPart = entry.parts?.find(p => p && p.type === 'text' && typeof p.text === 'string');
            if (!textPart) continue;
            
            const userPrompt = textPart.text.toLowerCase();
            if (userPrompt.includes('stop caveman') || userPrompt.includes('disable caveman') || userPrompt.includes('normal mode')) {
                return; // pass through
            }
            
            const modeMatch = userPrompt.match(/caveman\s+(lite|full|ultra)/i);
            if (modeMatch) {
              const newMode = modeMatch[1].toLowerCase();
              if (newMode !== cavemanMode) {
                fs.writeFileSync(CONFIG_PATH, JSON.stringify({ mode: newMode }, null, 2));
                textPart.text += `\n[CAVEMAN MODE CHANGED TO: ${newMode.toUpperCase()}]\n`;
                return;
              }
            }
            
            
            if (userPrompt.includes('is caveman on') || userPrompt.includes('caveman status')) {
                textPart.text += `\n[SYSTEM STATUS INTERCEPT: Tell the user "Yes, Caveman ${cavemanMode.toUpperCase()} is currently active and intercepting prompts via hook." Do not search tools.]\n`;
                return;
            }
            const cavemanInstruction = `\n\n[COMMUNICATE IN CAVEMAN MODE: ${cavemanMode.toUpperCase()}]\n` +
              `Rules: Drop filler words (just/really/basically). ` +
              `Keep technical accuracy. Use short sentences. ` +
              `Code blocks unchanged. Be concise. Remember to answer "is caveman on?" affirmatively.\n`;
            
            textPart.text += cavemanInstruction;
            return;
        }
      }
    };
  }
};
