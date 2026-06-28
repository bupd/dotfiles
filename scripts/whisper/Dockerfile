FROM python:3.12-slim

ARG DEBIAN_FRONTEND=noninteractive

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_ROOT_USER_ACTION=ignore \
    PYTHONUNBUFFERED=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates ffmpeg \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --no-cache-dir \
    --index-url https://download.pytorch.org/whl/cu130 \
    "torch==2.12.1+cu130"

RUN python -m pip install --no-cache-dir \
    "numpy<2.4" \
    "numba==0.65.1" \
    "tiktoken==0.13.0" \
    "tqdm==4.68.3" \
    "more-itertools==11.1.0" \
    && python -m pip install --no-cache-dir --no-deps "openai-whisper==20250625"

ENTRYPOINT ["whisper"]
