begin;
    -- https://github.com/supabase/pg_graphql/issues/237
    create table blog_post(
        id int primary key,
        a text,
        b text,
        c text,
        d text,
        e text,
        f text
    );
    insert into public.blog_post
    values (1, 'a', 'b', 'c', 'd', 'e', 'f');
    select jsonb_pretty(
      graphql.resolve($$
        query {
          blogPostCollection(filter: {
            id: { eq: 1 }
          }) {
            edges {
              node {
                a
              }
            }
          }
          blogPostCollection {
            edges {
              node {
                b
              }
            }
          }
        }
      $$)
    );
rollback;
