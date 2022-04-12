UPDATE tabla set (
    campo1,campo2) = 
    coalesce(j.campojson1,tabla.campo1),
    coalesce(j.campojson2,tabla.campo2)
        FROM jsonb_populate_record(null::tabla_temp,jotason::jsonb) j

        WHERE tabla.campojson3 = j.campojson3 AND tabla.campo4 = j.campojson4
            RETURNING campo 3 into coderror;