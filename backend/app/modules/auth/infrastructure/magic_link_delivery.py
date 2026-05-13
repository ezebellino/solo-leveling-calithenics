from __future__ import annotations

import smtplib
from dataclasses import dataclass
from datetime import datetime
from email.message import EmailMessage

from app.core.config import settings
from app.modules.auth.domain.exceptions import AuthMagicLinkDeliveryFailedError


@dataclass(frozen=True, slots=True)
class MagicLinkDeliveryMessage:
    to_email: str
    display_name: str | None
    verification_url: str
    expires_at: datetime


class MagicLinkDeliveryGateway:
    def is_configured(self) -> bool:
        return bool(
            settings.auth_magic_link_email_from.strip()
            and settings.auth_magic_link_smtp_host.strip()
        )

    def send_magic_link(self, message: MagicLinkDeliveryMessage) -> None:
        if not self.is_configured():
            raise AuthMagicLinkDeliveryFailedError(
                "Magic link email delivery is not configured in this environment.",
            )

        email_message = EmailMessage()
        sender_name = settings.auth_magic_link_email_from_name.strip() or "Solo Leveling System"
        sender_email = settings.auth_magic_link_email_from.strip()
        email_message["Subject"] = "Tu acceso del Sistema esta listo"
        email_message["From"] = f"{sender_name} <{sender_email}>"
        email_message["To"] = message.to_email

        greeting_name = (message.display_name or "").strip() or message.to_email
        email_message.set_content(
            f"Hola {greeting_name},\n\n"
            "El Sistema preparo un acceso seguro para continuar con tu progreso.\n\n"
            f"Abrilo desde este enlace:\n{message.verification_url}\n\n"
            f"Expira: {message.expires_at.isoformat()}\n\n"
            "Si no solicitaste este acceso, ignora este correo."
        )

        try:
            smtp_client = self._build_client()
            with smtp_client as client:
                client.ehlo()
                if settings.auth_magic_link_smtp_use_tls and not settings.auth_magic_link_smtp_use_ssl:
                    client.starttls()
                    client.ehlo()
                username = settings.auth_magic_link_smtp_username.strip()
                if username:
                    client.login(username, settings.auth_magic_link_smtp_password)
                client.send_message(email_message)
        except Exception as exc:  # pragma: no cover
            raise AuthMagicLinkDeliveryFailedError(
                "The System could not deliver the magic link email.",
            ) from exc

    def _build_client(self):
        host = settings.auth_magic_link_smtp_host.strip()
        port = settings.auth_magic_link_smtp_port
        timeout_seconds = 10
        if settings.auth_magic_link_smtp_use_ssl:
            return smtplib.SMTP_SSL(host, port, timeout=timeout_seconds)
        return smtplib.SMTP(host, port, timeout=timeout_seconds)
