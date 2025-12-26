# 👨‍🍳 Seubert Assistent Pro
### Digitale Effizienz & Sicherheit in der Profi-Küche

Der **Seubert Assistent Pro** ist eine spezialisierte iOS-App für die moderne Gastronomie. Er fungiert als digitale Schnittstelle zwischen physischen Produkten und kritischen Zubereitungsinformationen. Durch den Einsatz von OCR-Technologie (Texterkennung) und einer intelligenten Hybrid-Datenbank ermöglicht die App den sofortigen Zugriff auf Garzeiten, Temperaturen und Allergen-Informationen direkt am Einsatzort.

---

## 🎯 Das Problem & Die Lösung

**Problem:** In der Hektik des Küchenalltags gehen Informationen über exakte Kerntemperaturen, Allergene oder spezifische Garzeiten oft unter. Das Nachschlagen in Papierlisten oder dicken Katalogen ist zeitraubend und fehleranfällig.

**Lösung:** Eine native iOS-App, die Informationen unmittelbar dort verfügbar macht, wo sie gebraucht werden: **direkt am Produkt.**

---

## 🌟 Key Features

* **Instant-Info via Scan:** Kamera auf das Etikett halten – sofort erscheinen Garzeit und Temperatur.
* **Intelligente Badges:** Die App erkennt den Kontext. Steht im Text „Pfanne“, „Backen“ oder „Grill“, passt sich die Anzeige automatisch an.
* **Allergen-Klartext:** Kein Rätselraten mehr bei Codes wie „A“ oder „G“. Automatische Übersetzung in Klarschrift (z. B. Gluten, Milch, Sulfite).
* **One-Touch-Timer:** Zeitvorgaben werden aus dem Text extrahiert und können mit einem Klick gestartet werden.
* **Haptisches Feedback:** Bestätigt erfolgreiche Erkennungen durch physische Vibration.

---

## ⚙️ Technische Highlights

### 1. Smart Parsing (RegEx)
Die App nutzt hochpräzise **Regular Expressions**, um aus unstrukturierten Herstellertexten gezielt Daten wie:
* **KT 72°C** (Kerntemperatur)
* **180°C** (Ofentemperatur)
* **Zeitangaben** (in Minuten) zu extrahieren.

### 2. Hybrid-Suche
* **Lokal:** Eine pfeilschnelle CSV-Datenbank für Seubert-Spezialprodukte (funktioniert offline im Kühlhaus!).
* **Global:** Integration der **OpenFoodFacts API** zur Abfrage externer Barcodes (EAN).

### 3. Live-Filtering
Dynamische Volltextsuche nach Artikelnummern oder Namen, die sich bereits während der Eingabe aktualisiert.

---

## 🛠 Technische Details

### Architektur & Frameworks
* **Sprache:** Swift 6.0
* **UI-Framework:** SwiftUI (Deklaratives Design)
* **Design-Pattern:** MVVM (Model-View-ViewModel)
* **Networking:** Asynchrone API-Anbindung via `URLSession`

### Datenmodell (Auszug)

| Feld | Funktion |
| :--- | :--- |
| `id` | Eindeutige Artikelnummer / Barcode |
| `rawInstruction` | Ursprünglicher Zubereitungstext vom Hersteller |
| `ParsedInstruction` | Strukturiertes Objekt mit Ofentemp, Kern-Temp und Dauer |
| `ProductCategory` | Enum zur Steuerung von Icons (🥩 Meat, 🐟 Fish, 🥗 Veggie etc.) |

---

## 📱 User Interface (UI)
* **Dashboard:** Minimalistisches Design für schnellen Zugriff auf den Scanner.
* **Dark Mode Support:** Optimiert für Lichtverhältnisse in professionellen Großküchen.
* **Quick-Filter:** Blitzschnelles Umschalten zwischen Warengruppen via Kategorie-Chips.
* **Temperature Badges:** Visuelle Darstellung der Garstufen im modernen "Gradient-Look".

---

## 📖 Installation & Setup

1.  **Voraussetzungen:** Xcode 15+ und iOS 17+.
2.  **Datenquelle:** Die Datei `Produkte.csv` muss im Verzeichnis `Resources` liegen (Trennzeichen: `;`).
3.  **Deployment:**
    ```bash
    # Repository klonen
    git clone [https://github.com/DEIN_USERNAME/Seubert-Assistent.git](https://github.com/DEIN_USERNAME/Seubert-Assistent.git)
    ```
4.  **Build:** In Xcode öffnen und `Cmd + R` drücken.

---

## 📈 Nutzen für den Betrieb

1.  **Fehlerminimierung:** Immer die richtige Kerntemperatur im Blick (HACCP-konform).
2.  **Zeitersparnis:** Kein langes Suchen in Ordnern – mehr Fokus auf das Kochen.
3.  **Sicherheit:** Sofortige, verlässliche Auskunft bei Allergiker-Anfragen, auch für neues Personal.

---

## 🔮 Roadmap
- [ ] **Cloud-CMS:** Anbindung an eine Echtzeit-Datenbank zur Pflege der CSV.
- [ ] **Voice-Assistant:** Sprachausgabe der Zubereitungsschritte (Hands-free Modus).
- [ ] **HACCP-Export:** PDF-Generierung für die Dokumentation per Klick.

---
*Entwickelt für die moderne Gastronomie. Effizient. Sicher. Seubert.*
