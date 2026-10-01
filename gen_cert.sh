#!/bin/bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \ -keyout nginx/certs/vm1.key \ -out nginx/certs/vm1.crt \ -subj  "/CN=public.vm1.local" \ -addext "subjectAlName=DNS:public.vm1.local"
