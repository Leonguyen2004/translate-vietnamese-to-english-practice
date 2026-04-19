# Backend Database Model Diagram

Tài liệu này mô tả các thực thể backend trong `backend` và các quan hệ khóa ngoại chính. Bạn có thể sao chép phần `DBML` vào dbdiagram.io để trực quan hoá sơ đồ.

```dbml

Table users {
  id int [pk, increment]
  name varchar(100)
  username varchar(100) [unique]
  email varchar(100) [unique]
  phone_number varchar(20)
  date_birth date
  school varchar(100)
  password varchar
  role varchar(50)
  point int
  credit int
  enable boolean
  created_at datetime
  last_login datetime
  delete_flag boolean
  api_key varchar
  api_url varchar
}

Table topic {
  id int [pk, increment]
  name varchar(100)
  description text
  delete_flag boolean
  type varchar(50)
  note text
  created_at datetime
  image_url varchar
  image_id varchar
  user_id int
  language_id int
}

Table level {
  id int [pk, increment]
  name varchar(100)
  description text
  created_at datetime
  updated_at datetime
  delete_flag boolean
  language_id int
}

Table language {
  id int [pk, increment]
  name varchar(100)
  note text
  created_at datetime
  updated_at datetime
  delete_flag boolean
  language_code varchar(10) [unique]
}

Table lesson {
  id int [pk, increment]
  name varchar(100)
  paragraph text
  note text
  description text
  status varchar(50)
  delete_flag boolean
  type varchar(50)
  last_practice datetime
  created_at datetime
  updated_at datetime
  topic_id int
  level_id int
  language_id int
  user_id int
}

Table vocabulary {
  id int [pk, increment]
  term varchar(100)
  vi text
  type varchar(50)
  pronunciation varchar(100)
  example text
  audioUrl varchar
  imageUrl varchar
  collection_id int
  created_at datetime
  user_id int
}

Table flash_card {
  id int [pk, increment]
  imageUrl varchar
  vocab_id int
}

Table collectionvocab {
  id int [pk, increment]
  name varchar(100)
}

Table collectionvoca {
  id int [pk, increment]
  name varchar(100)
  user_id int
}

Table history {
  id int [pk, increment]
  question text
  answer text
  result varchar
  created_at datetime
  user_id int
  lesson_id int
}

Table status_lesson {
  id int [pk, increment]
  name_status varchar(20)
}

Table status_leson_user {
  id int [pk, increment]
  user_id int
  lesson_id int
  status int
}

Table notification {
  id int [pk, increment]
  type varchar(50)
  message text
  link varchar(255)
  created_at datetime
  is_read boolean
  user_sender int
  user_receive int
}

Table feedback {
  id int [pk, increment]
  description text
  created_at datetime
  user_id int
}

Table suggest_vocabulary {
  id int [pk, increment]
  term varchar(100)
  vietnamese text
  type varchar(50)
  pronunciation varchar(100)
  example text
  delete_flag boolean
  lesson_id int
}

Table payment {
  id int [pk, increment]
  created_at datetime
  price decimal(10, 2)
  status varchar(50)
  user_id int
}

Table verification_token {
  id int [pk, increment]
  user_id int
  token varchar
  expired_time datetime
  token_type varchar(50)
  created_at datetime
}

Table invalid_token {
  id varchar [pk]
  expiry_time datetime
}

Ref: topic.language_id > language.id
Ref: level.language_id > language.id
Ref: lesson.topic_id > topic.id
Ref: lesson.level_id > level.id
Ref: lesson.language_id > language.id
Ref: lesson.user_id > users.id
Ref: vocabulary.collection_id > collectionvocab.id
Ref: vocabulary.user_id > users.id
Ref: flash_card.vocab_id > vocabulary.id
Ref: history.user_id > users.id
Ref: history.lesson_id > lesson.id
Ref: status_leson_user.user_id > users.id
Ref: status_leson_user.lesson_id > lesson.id
Ref: notification.user_sender > users.id
Ref: notification.user_receive > users.id
Ref: feedback.user_id > users.id
Ref: suggest_vocabulary.lesson_id > lesson.id
Ref: payment.user_id > users.id
Ref: verification_token.user_id > users.id
Ref: collectionvoca.user_id > users.id
Ref: topic.user_id > users.id

```
