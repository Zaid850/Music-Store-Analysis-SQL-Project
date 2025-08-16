-- Drop in dependency-safe order
DROP TABLE IF EXISTS playlist_track;
DROP TABLE IF EXISTS invoice_line;
DROP TABLE IF EXISTS invoice;
DROP TABLE IF EXISTS track;
DROP TABLE IF EXISTS playlist;
DROP TABLE IF EXISTS album;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS artist;
DROP TABLE IF EXISTS media_type;
DROP TABLE IF EXISTS genre;

-- Master tables
CREATE TABLE artist (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE media_type (
    media_type_id INT PRIMARY KEY,
    name VARCHAR(120)
);

CREATE TABLE genre (
    genre_id INT PRIMARY KEY,
    name VARCHAR(120)
);

-- Employees (FK is DEFERRABLE so CSV import won’t fail on manager rows)
CREATE TABLE employee (
    employee_id INT PRIMARY KEY,
    last_name VARCHAR(100),
    first_name VARCHAR(100),
    title VARCHAR(100),
    reports_to INT,
    levels VARCHAR(10),
    birth_date TIMESTAMP,
    hire_date TIMESTAMP,
    address VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    phone VARCHAR(30),
    fax VARCHAR(30),
    email VARCHAR(150)
);
ALTER TABLE employee
  ADD CONSTRAINT fk_employee_manager
  FOREIGN KEY (reports_to) REFERENCES employee(employee_id)
  ON DELETE SET NULL
  DEFERRABLE INITIALLY DEFERRED;

  ALTER TABLE public.employee
  DROP CONSTRAINT IF EXISTS fk_employee_manager;


CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name  VARCHAR(100),
    company    VARCHAR(150),
    address    VARCHAR(200),
    city       VARCHAR(100),
    state      VARCHAR(100),
    country    VARCHAR(100),
    postal_code VARCHAR(20),
    phone      VARCHAR(30),
    fax        VARCHAR(30),
    email      VARCHAR(150),
    support_rep_id INT
);
ALTER TABLE customer
  ADD CONSTRAINT fk_customer_support_rep
  FOREIGN KEY (support_rep_id) REFERENCES employee(employee_id)
  ON DELETE SET NULL;

CREATE TABLE album (
    album_id INT PRIMARY KEY,
    title    VARCHAR(150),
    artist_id INT REFERENCES artist(artist_id) ON DELETE CASCADE
);

CREATE TABLE track (
    track_id INT PRIMARY KEY,
    name VARCHAR(200),
    album_id INT REFERENCES album(album_id) ON DELETE CASCADE,
    media_type_id INT REFERENCES media_type(media_type_id) ON DELETE SET NULL,
    genre_id INT REFERENCES genre(genre_id) ON DELETE SET NULL,
    composer VARCHAR(200),
    milliseconds INT,
    bytes INT,
    unit_price NUMERIC(5,2)
);

CREATE TABLE playlist (
    playlist_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE playlist_track (
    playlist_id INT,
    track_id INT,
    PRIMARY KEY (playlist_id, track_id),
    FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id) ON DELETE CASCADE,
    FOREIGN KEY (track_id)    REFERENCES track(track_id)     ON DELETE CASCADE
);

CREATE TABLE invoice (
    invoice_id INT PRIMARY KEY,
    customer_id INT REFERENCES customer(customer_id) ON DELETE CASCADE,
    invoice_date DATE,
    billing_address VARCHAR(200),
    billing_city VARCHAR(100),
    billing_state VARCHAR(100),
    billing_country VARCHAR(100),
    billing_postal_code VARCHAR(20),
    total NUMERIC(10,2)
);

CREATE TABLE invoice_line (
    invoice_line_id INT PRIMARY KEY,
    invoice_id INT REFERENCES invoice(invoice_id) ON DELETE CASCADE,
    track_id   INT REFERENCES track(track_id)     ON DELETE RESTRICT,
    unit_price NUMERIC(5,2),
    quantity INT
);
