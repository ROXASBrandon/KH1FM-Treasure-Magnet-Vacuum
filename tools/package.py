"""Package the standalone repository as a ready-to-import OpenKH ZIP."""
from pathlib import Path
import hashlib
import zipfile
ROOT = Path(__file__).resolve().parents[1]
ARCHIVE = 'Treasure-Magnet-Vacuum-v1.0.0.zip'
SCRIPT = 'kh1_treasure_magnet_vacuum.lua'

files = ['mod.yml', 'README.md', 'CREDITS.md', 'CHANGELOG.md',
         'scripts/'+SCRIPT, 'images/banner.png', 'tools/package.py']
output = ROOT/'downloads'
output.mkdir(exist_ok=True)
archive = output/ARCHIVE
with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_DEFLATED) as z:
    for name in files:
        payload = (ROOT/name).read_bytes()
        for marker in ('/'+'mnt/', 'Users'+'/', 'Users'+chr(92)):
            for encoding in ('utf-8', 'utf-16le'):
                if marker.encode(encoding) in payload:
                    raise ValueError('Private path in '+name)
        info = zipfile.ZipInfo(name, date_time=(2026, 10, 7, 0, 0, 0))
        info.compress_type = zipfile.ZIP_DEFLATED
        info.external_attr = 0o100644 << 16
        z.writestr(info, payload)
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None and z.namelist() == files
    for name in files:
        assert z.read(name) == (ROOT/name).read_bytes(), name
(output/'SHA256SUMS.txt').write_text(
    hashlib.sha256(archive.read_bytes()).hexdigest()+'  '+archive.name+'\n')
print(archive)
