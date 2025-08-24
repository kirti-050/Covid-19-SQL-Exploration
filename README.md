# COVID-19 SQL Data Exploration (Portfolio Project)

This repository contains my end-to-end SQL exploration of COVID-19 cases, deaths, and vaccinations.  
It demonstrates practical SQL techniques including data cleaning with `TRY_CAST`, window functions for rolling totals, temp tables, and a reusable view for analysis.

> **File to run:** `Covid Portfolio Project 1.sql` (or open the same SQL pasted at the repo root, if you prefer).

---

## 🧩 What this project includes
- **Data cleaning & type safety** using `TRY_CAST` to avoid conversion errors (varchar → numeric/date).
- **Window functions** to compute a rolling sum of vaccinations per location.
- **Percent metrics** such as `% of population vaccinated` with safe division (`NULLIF`).
- **Temp tables** (e.g., `#PercentPopulationVaccinated`) for staged transforms.
- **A view** (`PercentpopulationVaccinated`) for reusable downstream queries.
- **Join logic** between `CovidDeaths` and `CovidVaccinations` on `location` and `date`.

> Tables used: `CovidDeaths`, `CovidVaccinations` (commonly from an OWID export).  
> Target RDBMS: **Microsoft SQL Server** (tested with SSMS).

---


## 🚀 How to run
1. Open **SQL Server Management Studio (SSMS)** (or your SQL client).
2. Ensure your database has the two tables: `CovidDeaths`, `CovidVaccinations` (same schema used in the script).
3. Open `sql/covid_sql_exploration.sql` and run it top-to-bottom, or run section-by-section:
   - Cleaning & `TRY_CAST` conversions
   - Rolling vaccination totals with window functions
   - Temp table creation and use
   - View creation: `PercentpopulationVaccinated`
4. Query examples you can run after the script:
   ```sql
   SELECT TOP 50 *
   FROM PercentpopulationVaccinated
   ORDER BY Location, [Date];

   SELECT Location,
          MAX(RollingPeopleVaccinated * 100.0 / NULLIF(Population, 0)) AS MaxPercentVaccinated
   FROM PercentpopulationVaccinated
   GROUP BY Location
   ORDER BY MaxPercentVaccinated DESC;
   ```


---

## 📝 Notes & gotchas
- If your source columns arrive as **varchar** (common with CSV imports), use `TRY_CAST` to avoid hard failures.
- When joining on dates that are stored as text, use `TRY_CAST(date_col AS date)` on both sides of the join.
- Always guard division: `numerator * 100.0 / NULLIF(denominator, 0)`.
- Temp tables (`#...`) are session-scoped; views are saved database objects.

---

## 🧪 Sample verification queries
```sql
-- Find rows with invalid dates in your raw tables
SELECT DISTINCT date
FROM CovidDeaths
WHERE TRY_CAST(date AS date) IS NULL AND date IS NOT NULL;

SELECT DISTINCT date
FROM CovidVaccinations
WHERE TRY_CAST(date AS date) IS NULL AND date IS NOT NULL;
```


---

## 👤 Author
**Kirti Srivastava**  
BCA (Data Science & AI) | SQL • Python • ML

If you use or learn from this repo, a ⭐ on GitHub would make my day!
