#!/usr/bin/env python3
"""Run a program on a pseudo-terminal, feed it keys, print the screen.

    terminal.py KEYS PROGRAM [ARG...]

KEYS is one string of key names (up down enter esc bs ctrlc space) or
characters, separated by spaces.
After the program has started, and after each key, the screen of a small
terminal emulator is printed in a box as wide as the terminal, under the
name of the key, so the transcript shows what a person would see: frames
replaced in place, lines wrapped where the terminal wraps them, the
terminal restored on the way out.  At the end, how the program exited
and whether echo and canonical mode are back.

This is what urt/check diffs for the cases under urt/tests/pty.  Only
the standard library is used.
"""

import fcntl
import os
import pty
import re
import select
import struct
import sys
import termios
import time

COLS, ROWS = 60, 24
KEYS = {'up': '\x1b[A', 'down': '\x1b[B', 'enter': '\r', 'esc': '\x1b',
        'bs': '\x7f', 'ctrlc': '\x03', 'space': ' '}


class Screen:
    """Enough of a VT100 for the sequences tui.c emits."""

    def __init__(self):
        self.lines = [[''] * COLS for _ in range(ROWS)]
        self.y = self.x = 0
        self.buf = ''

    def newline(self):
        self.y += 1
        if self.y >= ROWS:
            self.lines.pop(0)
            self.lines.append([''] * COLS)
            self.y = ROWS - 1

    def put(self, ch):
        if self.x >= COLS:
            self.x = 0
            self.newline()
        self.lines[self.y][self.x] = ch
        self.x += 1

    def feed(self, data):
        self.buf += data
        while self.buf:
            c = self.buf[0]
            if c == '\x1b':
                m = re.match(r'\x1b\[(\??)([0-9;]*)([A-Za-z])', self.buf)
                if not m:
                    if len(self.buf) < 8:
                        return          # a partial sequence; wait for the rest
                    self.buf = self.buf[1:]
                    continue
                private, arg, cmd = m.groups()
                n = int(arg) if arg.isdigit() else 1
                self.buf = self.buf[m.end():]
                if private:
                    continue            # cursor on/off
                if cmd == 'A':
                    self.y = max(0, self.y - n)
                elif cmd == 'B':
                    self.y = min(ROWS - 1, self.y + n)
                elif cmd == 'G':
                    self.x = n - 1
                elif cmd == 'J':
                    self.lines[self.y][self.x:] = [''] * (COLS - self.x)
                    for r in range(self.y + 1, ROWS):
                        self.lines[r] = [''] * COLS
                continue
            self.buf = self.buf[1:]
            if c == '\r':
                self.x = 0
            elif c == '\n':
                self.newline()
            elif c == '\b':
                self.x = max(0, self.x - 1)
            else:
                self.put(c)

    def show(self, label):
        """The screen in a box, without the blank rows under the last
        line written; each row is one cell per column, so a row is as
        wide as the terminal and the box shows where lines wrapped."""
        rows = [''.join(ch or ' ' for ch in line) for line in self.lines]
        while rows and not rows[-1].strip():
            rows.pop()
        edge = '+' + '-' * COLS + '+'
        print(label)
        print(edge)
        for row in rows:
            print('|' + row + '|')
        print(edge)


def main():
    keys, command = sys.argv[1].split(), sys.argv[2:]
    screen = Screen()
    pid, fd = pty.fork()
    if pid == 0:
        os.environ['TERM'] = 'xterm-256color'
        os.environ['LANG'] = 'C.UTF-8'
        os.execvp(command[0], command)
    fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack('HHHH', ROWS, COLS, 0, 0))

    def pump(seconds):
        end = time.time() + seconds
        alive = True
        while time.time() < end:
            ready, _, _ = select.select([fd], [], [], 0.05)
            if ready:
                try:
                    data = os.read(fd, 65536)
                except OSError:
                    data = b''
                if not data:
                    alive = False
                    break
                screen.feed(data.decode('utf-8', 'replace'))
        return alive

    pump(0.8)
    screen.show('start')
    for k in keys:
        os.write(fd, KEYS.get(k, k).encode())
        alive = pump(0.4)
        screen.show(k)
        if not alive:
            break
    if pump(0.4):
        # Still waiting for keys: end it as a closed terminal would, which
        # also shows whether the handler restores the tty.
        os.kill(pid, 15)
        pump(0.4)
        print('still running after the last key; sent SIGTERM')
    _, status = os.waitpid(pid, 0)
    if os.WIFSIGNALED(status):
        print('exit: signal %d' % os.WTERMSIG(status))
    else:
        print('exit: status %d' % os.WEXITSTATUS(status))
    attrs = termios.tcgetattr(fd)
    print('tty restored: echo=%s icanon=%s' %
          (bool(attrs[3] & termios.ECHO), bool(attrs[3] & termios.ICANON)))


if __name__ == '__main__':
    main()
