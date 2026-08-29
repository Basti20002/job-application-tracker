CREATE TABLE applications (
    id INTEGER PRIMARY KEY,
    company_name TEXT NOT NULL,
    job_title TEXT NOT NULL,
    location TEXT,
    date_applied TEXT,
    status TEXT NOT NULL DEFAULT 'applied' CHECK (status IN
 ('applied', 'interviewing', 'offer','researching', 'rejected', 'withdrawn')),
    source TEXT,
    contact TEXT,
    salary_min INTEGER,
    salary_max INTEGER,
    prerequisites TEXT,
    notes TEXT,
    employment_type TEXT DEFAULT 'unspecified' CHECK (employment_type IN ('werkstudent',
 'praktikum','permanent','fixed-term','unspecified'))
);
