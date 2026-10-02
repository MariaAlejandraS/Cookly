
package com.example.cookly

import android.app.Application
import com.example.cookly.data.AppDatabase

/** Punto de entrada de la app: inicializa Room de forma perezosa. */
class CooklyApplication : Application() {
    val database: AppDatabase by lazy { AppDatabase.getInstance(this) }
}
