CREATE TABLE applications (
    id INTEGER PRIMARY KEY,
    company_name TEXT NOT NULL,
    job_title TEXT NOT NULL,
    location TEXT,
    date_applied TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'applied' CHECK (status IN
 ('applied', 'interviewing', 'offer', 'rejected', ' withdrawn')),
    source TEXT,
    contact TEXT,
    salary_min INTEGER,
    salary_max INTEGER,
    prerequisites TEXT,
    notes TEXT
);
