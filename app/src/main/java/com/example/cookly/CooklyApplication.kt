package com.example.cookly

import android.app.Application
import com.example.cookly.data.AppDatabase

/** Punto de entrada: Room se inicializa de forma perezosa; Auth lo maneja Firebase. */
class CooklyApplication : Application() {
    val database: AppDatabase by lazy { AppDatabase.getInstance(this) }
}
