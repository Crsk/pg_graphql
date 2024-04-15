begin;

    create table users(
        id uuid primary key,
        email character varying (255),
        phone text
    );

    insert into public.users(id, email, phone)
    values
        ('dd5add8a-7dd2-4495-bc1a-a1dfe95ef23a', 'a@b.com', '987654321');

    create or replace view users_with_phone with (security_invoker) as select
        id,
        email,
        phone
    from public.users
    where phone is not null;

    create table polls(
        id uuid primary key,
        user_id uuid references users(id)
    );

    insert into public.polls(id, user_id)
    values ('98813159-4814-42fa-911d-5cc900bd80b8', 'dd5add8a-7dd2-4495-bc1a-a1dfe95ef23a');

    create
    or replace function author (rec polls) returns users_with_phone stable strict language sql security definer
    set
        search_path = public as $$
        select
            *
        from users_with_phone u
        where u.id = $1.user_id;
    $$;

    select graphql.resolve($$
    {
        pollsCollection {
          edges {
            node {
              author {
                id,
                email,
                phone
              }
            }
          }
        }
      }
    $$);

rollback;
