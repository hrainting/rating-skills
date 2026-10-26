#!/usr/bin/env python3
"""Parse cloudflare_temp_email raw RFC822 rows into the parsed API shape."""

from __future__ import annotations

import argparse
import json
import sys
from email import policy
from email.message import Message
from email.parser import Parser
from typing import Any


def content_text(part: Message) -> str:
    try:
        value = part.get_content()
        if isinstance(value, str):
            return value
    except (LookupError, UnicodeDecodeError, AttributeError):
        pass

    payload = part.get_payload(decode=True)
    if payload is None:
        raw = part.get_payload()
        return raw if isinstance(raw, str) else ""
    charset = part.get_content_charset() or "utf-8"
    try:
        return payload.decode(charset, errors="replace")
    except LookupError:
        return payload.decode("utf-8", errors="replace")


def parse_row(row: dict[str, Any]) -> dict[str, Any]:
    raw = row.get("raw")
    if not isinstance(raw, str) or not raw:
        return {key: value for key, value in row.items() if key != "raw"}

    message = Parser(policy=policy.default).parsestr(raw)
    text_parts: list[str] = []
    html_parts: list[str] = []
    attachments: list[dict[str, Any]] = []

    for part in message.walk():
        if part.is_multipart():
            continue

        content_type = part.get_content_type()
        disposition = part.get_content_disposition()
        filename = part.get_filename()
        payload = part.get_payload(decode=True) or b""

        if disposition == "attachment" or filename:
            attachments.append(
                {
                    "filename": filename or "",
                    "mimeType": content_type,
                    "disposition": disposition or "attachment",
                    "size": len(payload),
                }
            )
        elif content_type == "text/plain":
            text_parts.append(content_text(part))
        elif content_type == "text/html":
            html_parts.append(content_text(part))

    parsed = {key: value for key, value in row.items() if key != "raw"}
    parsed.update(
        {
            "sender": str(message.get("From", "")),
            "subject": str(message.get("Subject", "")),
            "text": "\n".join(part for part in text_parts if part),
            "html": "\n".join(part for part in html_parts if part),
            "attachments": attachments,
        }
    )
    return parsed


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=("list", "one"))
    args = parser.parse_args()

    payload = json.load(sys.stdin)
    if args.mode == "list":
        if not isinstance(payload, dict):
            raise ValueError("list payload must be an object")
        rows = payload.get("results", [])
        if not isinstance(rows, list):
            raise ValueError("results must be an array")
        result = dict(payload)
        result["results"] = [parse_row(row) for row in rows if isinstance(row, dict)]
    else:
        result = parse_row(payload) if isinstance(payload, dict) else payload

    json.dump(result, sys.stdout, ensure_ascii=False, separators=(",", ":"))
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
