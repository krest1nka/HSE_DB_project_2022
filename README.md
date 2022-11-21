# 1

- Владелец - кто владеет картиной на данный момент
- Место хранения - где картина находится на данный момент(музей, специальное хранилище и т.д.)
- Город - местонахождение хранилища
- Сделка - покупка/продажа/унаследование/etc. картины 

**Версионная** таблица для данных о владении картиной

# 2

#### a. 
![](2a.jpg)

#### b. 
![](2b_ver2.jpg)

#### c.
| **Artist** |                |                          |          |                |
|------------|----------------|--------------------------|----------|----------------|
| **PK/FK**  | **Name**       | **Description**          | **Type** | **Constraint** |
| PK         | artist_id      | Индентификатор художника | INTEGER  | PRIMARY KEY    |
|            | artist_name    | Имя художника            | STRING   | NOT NULL       |
|            | artist_surname | Фамилия художника        | STRING   | NOT NULL       |

| **Painting** |               |                         |          |                                   |
|--------------|---------------|-------------------------|----------|-----------------------------------|
| **PK/FK**    | **Name**      | **Description**         | **Type** | **Constraint**                    |
| PK           | painting_id   | Индентификатор картины  | INTEGER  | PRIMARY KEY                       |
| FK           | artist_id     | Идентификатор художника | INTEGER  | FK references Artist(artist_id)   |
| FK           | storage_id    | Идентификатор хранилища | INTEGER  | FK references Storage(storage_id) |
|              | painting_name | Название картирны       | STRING   | NOT NULL                          |
|              | creation_date | Дата создания картины   | DATE     | CHECK(creation_date <= GETDATE()) |

| **Storage** |                  |                          |          |                             |
|-------------|------------------|--------------------------|----------|-----------------------------|
| **PK/FK**   | **Name**         | **Description**          | **Type** | **Constraint**              |
| PK          | storage_id       | Индентификатор хранилища | INTEGER  | PRIMARY KEY                 |
| FK          | city_id          | Идентификатор города     | INTEGER  | FK references City(city_id) |
|             | storage_name     | Название хранилища       | STRING   | NOT NULL                    |
|             | storage_capacity | Вместимость хранилища    | INTEGER  | СHECK(storage_capacity > 0) |

| **Owner** |                |                          |          |                |
|------------|----------------|--------------------------|----------|----------------|
| **PK/FK**  | **Name**       | **Description**          | **Type** | **Constraint** |
| PK         | owner_id      | Индентификатор владельца | INTEGER  | PRIMARY KEY    |
|            | owner_name    | Имя владельца          | STRING   | NOT NULL       |
|            | owner_surname | Фамилия владельца       | STRING   | NOT NULL       |

| **City** |                |                          |          |                |
|------------|----------------|--------------------------|----------|----------------|
| **PK/FK**  | **Name**       | **Description**          | **Type** | **Constraint** |
| PK         | city_id      | Индентификатор города | INTEGER  | PRIMARY KEY    |
|            | city_name    | Название города           | STRING   | NOT NULL       |
|            | country_name | Название страны        | STRING   | NOT NULL       |

| **Deal**  |             |                        |          |                                     |
|-----------|-------------|------------------------|----------|-------------------------------------|
| **PK/FK** | **Name**    | **Description**        | **Type** | **Constraint**                      |
| PK        | deal_id     | Индентификатор сделки  | INTEGER  | PRIMARY KEY                         |
| FK        | painting_id | Идентификатор картины  | INTEGER  | FK references Painting(painting_id) |
|           | deal_date   | Дата проведения сделки | DATE     | CHECK(deal_date <= GETDATE())                         |
|           | deal_price  | Стоимость картины      | INTEGER  | СHECK(deal_price >= 0)              |

| **Owner X Deal**  |          |                         |          |                               |
|-----------|----------|-------------------------|----------|-------------------------------|
| **PK/FK** | **Name** | **Description**         | **Type** | **Constraint**                |
| PK FK     | deal_id  | Индентификатор сделки   | INTEGER  | FK references Deal(deal_id) |
| PK FK     | owner_id | Идентификатор участника сделки | INTEGER  | FK references Owner(owner_id) |

| **Ownership history** |             |                          |          |                                     |
|-----------------------|-------------|--------------------------|----------|-------------------------------------|
| **PK/FK**             | **Name**    | **Description**          | **Type** | **Constraint**                      |
| PK FK                 | owner_id    | Индентификатор владельца | INTEGER  | FK references Owner(owner_id)       |
| PK FK                 | painting_id | Идентификатор картины    | INTEGER  | FK references Painting(painting_id) |
|                       | valid_from  | Дата начала владения     | DATE     | CHECK(deal_date <= GETDATE()) |
|                       | valid_until | Дата оканчания владения  | DATE     |  CHECK(deal_date <= GETDATE())     |
