import type { Register, ThemeSetArgs } from 'claude-code'

import { makeColors } from './make-colors.js'

// Cool slate with a teal accent: misty paper by day, a quiet server room by night.
const { theme, problems } = makeColors({
  label: 'Slate and teal',
  roles: { accent: '#0f8a8a', danger: '#c2453a', success: '#3f8a4f', warning: '#b07a12', pro: '#6a5aa8' },
  light: {
    gray: {
      anchors: {
        'surface-0': '#e9edf0',
        'surface-1': '#f1f4f6',
        'surface-2': '#f8fafb',
        'text-primary': '#1b2329',
        'text-secondary': '#3d4a54',
        'text-muted': '#56636d',
      },
    },
  },
  dark: {
    gray: {
      anchors: {
        'surface-0': '#14191d',
        'surface-1': '#1a2126',
        'surface-2': '#20282e',
        'surface-3': '#262f36',
        'text-primary': '#e6edf1',
        'text-secondary': '#c0cbd2',
        'text-muted': '#98a6b0',
      },
    },
  },
})

const LOOK: ThemeSetArgs = { colors: theme }

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const unpainted = problems.find(line => line.startsWith("Desktop won't paint"))

    if (unpainted !== undefined) {
      $.ui.toast(unpainted)
    }
    const set = await $.theme.set(LOOK)

    if (!set.isDrawn) {
      $.ui.status(set.reason)
    }

    return next(e)
  })
}
