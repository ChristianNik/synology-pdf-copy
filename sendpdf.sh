#!/bin/bash

# Pfad zum Ordner, der überwacht werden soll
watch_folder="/volume1/docker/paperlessngx/media/documents/archive"
# watch_folder="/volume1/docker/paperlessngx/pdf"


# Email-Adresse, an die die PDF-Dateien gesendet werden sollen
email_address="example@email.com"




# Überwache den Ordner auf neue PDF-Dateien
while true; do
  # Verwende find, um alle PDF-Dateien im Ordner und in allen Unterordnern aufzulisten
  pdf_files=$(find "$watch_folder" -type f -name "*.pdf")

  # Überprüfen, ob es neue PDF-Dateien gibt
  while read -r pdf_file; do
    # Überspringe die PDF-Datei, wenn sie bereits verarbeitet wurde
    processed_file="$pdf_file.processed"
    if [ -f "$processed_file" ]; then
      continue
    fi

    # Überprüfe, ob die PDF-Datei existiert
    if [ ! -f "$pdf_file" ]; then
     echo "Skipping [not_exist]: $pdf_file"
      continue
    fi
    
    echo "Found: $pdf_file"

    # Verwende den Dateinamen als Betreff für die Email
    subject="$(basename "$pdf_file")"
    filename="basename \"$pdf_file\""
    
    echo $filename

    # Sende die PDF-Datei per Email
    # echo "Sending $pdf_file to $email_address with subject $subject..."
    sendmail -t <<EOF
Subject: $subject
From: $email_address
To: $email_address
MIME-Version: 1.0
Content-Type: text/plain; name="$filename"
Content-Disposition: attachment; filename="$filename"
Content-Transfer-Encoding: base64

$(base64 "$pdf_file")
EOF

    # Markiere die PDF-Datei als verarbeitet
    touch "$processed_file"
  done <<< "$pdf_files"

  # Warte eine Minute, bevor der nächste Durchlauf gestartet wird
  sleep 60
done
