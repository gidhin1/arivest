import hashlib
import hmac
import os
import secrets
from datetime import datetime, timedelta, timezone


def normalize_email(email: str) -> str:
    return email.strip().lower()


def hash_password(password: str, salt_hex: str = "") -> tuple[str, str]:
    salt = bytes.fromhex(salt_hex) if salt_hex else secrets.token_bytes(16)
    digest = hashlib.pbkdf2_hmac(
        "sha256",
        password.encode("utf-8"),
        salt,
        390_000,
        dklen=32,
    )
    return (salt.hex(), digest.hex())


def verify_password(password: str, salt_hex: str, expected_hash_hex: str) -> bool:
    _, calculated = hash_password(password=password, salt_hex=salt_hex)
    return hmac.compare_digest(calculated, expected_hash_hex)


def generate_session_token() -> str:
    return secrets.token_urlsafe(48)


def hash_session_token(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def session_expiry(hours_default: int = 168) -> datetime:
    raw_value = os.getenv("ARIVEST_SESSION_TTL_HOURS", str(hours_default))
    try:
        ttl_hours = int(raw_value)
    except ValueError:
        ttl_hours = hours_default
    ttl_hours = max(1, min(ttl_hours, 24 * 180))
    return datetime.now(timezone.utc) + timedelta(hours=ttl_hours)

