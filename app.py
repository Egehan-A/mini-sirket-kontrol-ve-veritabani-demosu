import psycopg2
import tkinter as tk
from tkinter import messagebox
import csv

DB_HOST = "localhost"
DB_NAME = "mini_sirket"
DB_USER = "postgres"
DB_PASS = "11Oa8668"

def baglanti_al():
    return psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASS
    )

def listele():
    try:
        conn = baglanti_al()
        cur = conn.cursor()
        cur.execute("SELECT id, ad, soyad, maas, departman FROM vw_calisan_detay")
        veriler = cur.fetchall()
        
        sonuc_kutusu.delete("1.0", tk.END)
        
        toplam_maas = 0
        en_yuksek = 0
        kisi_sayisi = len(veriler)
        
        for satir in veriler:
            metin = f"ID: {satir[0]} | {satir[1]} {satir[2]} | Maaş: {satir[3]} TL | Bölüm: {satir[4]}\n"
            sonuc_kutusu.insert(tk.END, metin)
            
            toplam_maas += satir[3]
            if satir[3] > en_yuksek:
                en_yuksek = satir[3]
        
        if kisi_sayisi > 0:
            ort = toplam_maas / kisi_sayisi
            lbl_istatistik.config(text=f"Ortalama Maaş: {ort:.2f} TL | En Yüksek: {en_yuksek} TL")
        else:
            lbl_istatistik.config(text="Sistemde çalışan yok.")
            
    except Exception as e:
        print("Hata:", e)
    finally:
        if conn: conn.close()

def calisan_kaydet():
    ad = ent_ad.get()
    soyad = ent_soyad.get()
    yas = ent_yas.get()
    maas = ent_maas.get()
    dep_id = ent_dep.get()
    
    if ad == "" or soyad == "":
        messagebox.showwarning("Uyarı", "Ad ve soyad girmelisin!")
        return

    try:
        conn = baglanti_al()
        cur = conn.cursor()
        cur.execute("CALL sp_calisan_ekle(%s, %s, %s, %s, %s)", 
                    (ad, soyad, int(yas), int(maas), int(dep_id)))
        conn.commit()
        messagebox.showinfo("Bilgi", "Kayıt başarılı.")
        listele()
    except Exception as e:
        print("Ekleme hatası:", e)
        messagebox.showerror("Hata", "Ekleme yapılamadı.")
    finally:
        if conn: conn.close()

def maas_guncelle():
    c_id = ent_g_id.get()
    y_maas = ent_g_maas.get()
    
    try:
        conn = baglanti_al()
        cur = conn.cursor()
        cur.execute("CALL sp_maas_guncelle(%s, %s)", (int(c_id), int(y_maas)))
        conn.commit()
        messagebox.showinfo("Tamam", "Maaş güncellendi.")
        listele()
    except Exception as e:
        messagebox.showerror("Hata", "Güncelleme olmadı.")
    finally:
        if conn: conn.close()

def rapor_olustur():
    try:
        conn = baglanti_al()
        cur = conn.cursor()
        cur.execute("SELECT * FROM vw_calisan_detay")
        rows = cur.fetchall()
        
        with open('sirket_verileri.csv', 'w', newline='', encoding='utf-8') as f:
            yazici = csv.writer(f)
            yazici.writerow(['ID', 'Ad', 'Soyad', 'Maas', 'Bölüm', 'Giriş Tarihi'])
            yazici.writerows(rows)
        messagebox.showinfo("CSV", "Rapor oluşturuldu.")
    except Exception as e:
        print("Hata:", e)

root = tk.Tk()
root.title("Personel Yönetim Sistemi")
root.geometry("500x650")

tk.Label(root, text="-- Yeni Kayıt --", font=("Arial", 10, "bold")).pack(pady=5)
tk.Label(root, text="Ad:").pack()
ent_ad = tk.Entry(root); ent_ad.pack()
tk.Label(root, text="Soyad:").pack()
ent_soyad = tk.Entry(root); ent_soyad.pack()
tk.Label(root, text="Yaş:").pack()
ent_yas = tk.Entry(root); ent_yas.pack()
tk.Label(root, text="Maaş:").pack()
ent_maas = tk.Entry(root); ent_maas.pack()
tk.Label(root, text="Departman ID:").pack()
ent_dep = tk.Entry(root); ent_dep.pack()

tk.Button(root, text="Kaydet", command=calisan_kaydet).pack(pady=10)

tk.Label(root, text="-- Maaş Güncelle --", font=("Arial", 10, "bold")).pack(pady=5)
tk.Label(root, text="Çalışan ID:").pack()
ent_g_id = tk.Entry(root); ent_g_id.pack()
tk.Label(root, text="Yeni Maaş:").pack()
ent_g_maas = tk.Entry(root); ent_g_maas.pack()
tk.Button(root, text="Güncelle", command=maas_guncelle).pack(pady=5)

tk.Label(root, text="----------------------------------").pack()

lbl_istatistik = tk.Label(root, text="Ortalama Maaş: 0 TL | En Yüksek: 0 TL", fg="blue")
lbl_istatistik.pack(pady=5)

btn_frame = tk.Frame(root)
btn_frame.pack()
tk.Button(btn_frame, text="Listele", width=15, command=listele).grid(row=0, column=0, padx=5, pady=5)
tk.Button(btn_frame, text="CSV Rapor", width=15, command=rapor_olustur).grid(row=0, column=1, padx=5, pady=5)

sonuc_kutusu = tk.Text(root, height=10, width=55)
sonuc_kutusu.pack(pady=10)

listele()

root.mainloop()