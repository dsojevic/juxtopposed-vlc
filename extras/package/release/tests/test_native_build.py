# SPDX-License-Identifier: GPL-2.0-or-later
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

SCRIPTS = Path(__file__).resolve().parents[1]


class NativeBuildTests(unittest.TestCase):
    def run_build(self, platform, *, existing=False, fail_proxy=False):
        with tempfile.TemporaryDirectory(prefix='native release ') as temp:
            root = Path(temp)
            scripts = root / 'extras/package/release'
            scripts.mkdir(parents=True)
            shutil.copyfile(SCRIPTS / 'build-native.sh', scripts / 'build-native.sh')
            (scripts / 'version.py').write_text('print("4.0.0-beta.4")\n')
            (scripts / 'build-medialibrary.sh').write_text('exit 0\n')
            record = '''import json, os, sys
from pathlib import Path
with Path(os.environ['NATIVE_TEST_LOG']).open('a') as stream:
    stream.write(json.dumps([Path(sys.argv[0]).name, *sys.argv[1:]]) + '\\n')
'''
            (scripts / 'package.py').write_text(record)
            commands = root / 'commands'
            commands.mkdir()
            fixtures = {
                'uname': 'import os\nprint(os.environ["NATIVE_TEST_PLATFORM"])\n',
                'brew': ('import os, sys\nfrom pathlib import Path\n'
                         'print(Path(os.environ["NATIVE_TEST_ROOT"]) / "brew" / '
                         '(sys.argv[2] if len(sys.argv) > 2 else ""))\n'),
                'meson': record + '''
if sys.argv[1] == 'test' and os.environ.get('NATIVE_TEST_FAIL_PROXY') == '1':
    raise SystemExit(23)
''',
            }
            for name, body in fixtures.items():
                command = commands / name
                command.write_text('#!/usr/bin/env python3\n' + body)
                command.chmod(0o755)
            target = 'macos' if platform == 'Darwin' else 'linux'
            if existing:
                build = root / ('build-release-' + target)
                build.mkdir()
                (build / 'build.ninja').touch()
            log = root / 'commands.jsonl'
            env = dict(os.environ, PATH=str(commands) + os.pathsep + os.environ['PATH'],
                       NATIVE_TEST_PLATFORM=platform, NATIVE_TEST_ROOT=str(root),
                       NATIVE_TEST_LOG=str(log), NATIVE_TEST_FAIL_PROXY=str(int(fail_proxy)),
                       QT_ROOT_DIR=str(root / 'Qt SDK'), JOBS='2')
            result = subprocess.run(['bash', str(scripts / 'build-native.sh')],
                                    env=env, text=True, capture_output=True, timeout=20)
            calls = [json.loads(line) for line in log.read_text().splitlines()]
            return result, calls

    def check_macos(self, existing):
        result, calls = self.run_build('Darwin', existing=existing)
        self.assertEqual(result.returncode, 0, result.stderr)
        setup = next(call for call in calls if call[:2] == ['meson', 'setup'])
        self.assertIn('-Dtests=enabled', setup)
        self.assertEqual('--reconfigure' in setup, existing)
        proxy_compile = next(i for i, call in enumerate(calls)
                             if call[:2] == ['meson', 'compile']
                             and call[-1] == 'test_src_misc_configured_proxy')
        proxy_test = next(i for i, call in enumerate(calls)
                          if call[:2] == ['meson', 'test'])
        install = next(i for i, call in enumerate(calls)
                       if call[:2] == ['meson', 'install'])
        package = next(i for i, call in enumerate(calls) if call[0] == 'package.py')
        self.assertEqual(calls[proxy_test][-1], 'test_src_misc_configured_proxy')
        self.assertIn('--no-rebuild', calls[proxy_test])
        self.assertLess(proxy_compile, proxy_test)
        self.assertLess(proxy_test, install)
        self.assertLess(install, package)

    def test_macos_fresh_build_checks_proxy_before_packaging(self):
        self.check_macos(False)

    def test_macos_reconfigure_enables_previously_disabled_tests(self):
        self.check_macos(True)

    def test_proxy_failure_prevents_install_and_package(self):
        result, calls = self.run_build('Darwin', fail_proxy=True)
        self.assertEqual(result.returncode, 23)
        self.assertFalse(any(call[:2] == ['meson', 'install'] for call in calls))
        self.assertFalse(any(call[0] == 'package.py' for call in calls))

    def test_linux_keeps_its_existing_release_checks(self):
        result, calls = self.run_build('Linux')
        self.assertEqual(result.returncode, 0, result.stderr)
        setup = next(call for call in calls if call[:2] == ['meson', 'setup'])
        self.assertIn('-Dtests=disabled', setup)
        self.assertFalse(any(call[:2] == ['meson', 'test'] for call in calls))
        self.assertTrue(any(call[0] == 'package.py' for call in calls))


if __name__ == '__main__':
    unittest.main()
