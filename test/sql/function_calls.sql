begin;

    -- Only volatilve functions appear on the mutation object
    create function add_ints(a int, b int)
        returns int language sql volatile
    as $$ select a + b; $$;

    select jsonb_pretty(graphql.resolve($$
        mutation {
            addInts(a: 40, b: 2)
        }
    $$));

rollback;