begin;

    CREATE TYPE plan AS ENUM ('free', 'pro', 'enterprise');

    create table account(
        id serial primary key,
        email varchar(255) not null,
        plan plan not null
    );

    insert into public.account(email, plan)
    values
        ('aardvark@x.com', 'free'),
        ('bat@x.com', 'pro'),
        ('cat@x.com', 'enterprise'),
        ('dog@x.com', 'free'),
        ('elephant@x.com', 'pro');

    savepoint a;

    -- AND filter zero expressions
    select jsonb_pretty(
        graphql.resolve($$
        {
            accountCollection(filter: {AND: []}) {
                edges {
                    node {
                        id
                        email
                    }
                }
            }
        }
        $$)
    );

    -- AND filter one expression
    select jsonb_pretty(
        graphql.resolve($$
        {
            accountCollection(filter: {AND: [{id: {eq: 1}}]}) {
                edges {
                    node {
                        id
                        email
                    }
                }
            }
        }
        $$)
    );

    -- AND filter two expressions
    select jsonb_pretty(
        graphql.resolve($$
        {
            accountCollection(filter: {AND: [{id: {eq: 1}}, {email: {eq: "aardvark@x.com"}}]}) {
                edges {
                    node {
                        id
                        email
                    }
                }
            }
        }
        $$)
    );

    -- AND filter three expressions
    select jsonb_pretty(
        graphql.resolve($$
        {
            accountCollection(filter: {AND: [{id: {eq: 1}}, {email: {eq: "aardvark@x.com"}}, {plan: {eq: "free"}}]}) {
                edges {
                    node {
                        id
                        email
                    }
                }
            }
        }
        $$)
    );

    -- OR filter zero expressions
    select jsonb_pretty(
        graphql.resolve($$
        {
            accountCollection(filter: {OR: []}) {
                edges {
                    node {
                        id
                        email
                    }
                }
            }
        }
        $$)
    );

    -- OR filter one expression
    select jsonb_pretty(
        graphql.resolve($$
        {
            accountCollection(filter: {OR: [{id: {eq: 1}}]}) {
                edges {
                    node {
                        id
                        email
                    }
                }
            }
        }
        $$)
    );

    -- OR filter two expressions
    select jsonb_pretty(
        graphql.resolve($$
        {
            accountCollection(filter: {OR: [{id: {eq: 3}}, {email: {eq: "elephant@x.com"}}]}) {
                edges {
                    node {
                        id
                        email
                    }
                }
            }
        }
        $$)
    );

    -- OR filter three expressions
    select jsonb_pretty(
        graphql.resolve($$
        {
            accountCollection(filter: {OR: [{id: {eq: 1}}, {email: {eq: "bat@x.com"}}, {plan: {eq: "enterprise"}}]}) {
                edges {
                    node {
                        id
                        email
                        plan
                    }
                }
            }
        }
        $$)
    );

    -- NOT filter zero expressions
    select jsonb_pretty(
        graphql.resolve($$
        {
            accountCollection(filter: {NOT: {}}) {
                edges {
                    node {
                        id
                        email
                    }
                }
            }
        }
        $$)
    );

    -- NOT filter one expression
    select jsonb_pretty(
        graphql.resolve($$
        {
            accountCollection(filter: {NOT: {id: {eq: 3}}}) {
                edges {
                    node {
                        id
                        email
                    }
                }
            }
        }
        $$)
    );

    -- multiple expressions inside a NOT filter are implicitly ANDed together
    -- NOT filter two expressions
    select jsonb_pretty(
        graphql.resolve($$
        {
            accountCollection(filter: {NOT: {id: {eq: 1}, email: {eq: "aardvark@x.com"}}}) {
                edges {
                    node {
                        id
                        email
                    }
                }
            }
        }
        $$)
    );

    -- multiple expressions inside a NOT filter are implicitly ANDed together
    -- NOT filter three expressions
    select jsonb_pretty(
        graphql.resolve($$
        {
            accountCollection(filter: {NOT: {id: {eq: 1}, email: {eq: "aardvark@x.com"}, plan: {eq: "free"}}}) {
                edges {
                    node {
                        id
                        email
                        plan
                    }
                }
            }
        }
        $$)
    );

    -- AND filter (explicit) nested inside OR
    select jsonb_pretty(
        graphql.resolve($$
        {
            accountCollection(
                filter: {
                    OR: [
                        { id: { eq: 3 } }
                        { id: { eq: 5 } }
                        { AND: [{ id: { eq: 1 } }, { email: { eq: "aardvark@x.com" } }] } # explicit AND
                    ]
                }
            ) {
                edges {
                node {
                    id
                    email
                }
                }
            }
        }
        $$)
    );

    -- AND filter (implicit) nested inside OR
    select jsonb_pretty(
        graphql.resolve($$
        {
            accountCollection(
                filter: {
                    OR: [
                        { id: { eq: 3 } }
                        { id: { eq: 5 } }
                        { id: { eq: 1 }, email: { eq: "aardvark@x.com" } } # implicit AND
                    ]
                }
            ) {
                edges {
                node {
                    id
                    email
                }
                }
            }
        }
        $$)
    );

    -- OR filter nested inside AND
    select jsonb_pretty(
        graphql.resolve($$
        {
            accountCollection(
                filter: {
                    AND: [
                        { id: { gt: 0 } }
                        { id: { lt: 4 } }
                        { OR: [{email: { eq: "bat@x.com" }}, {email: { eq: "cat@x.com" }}] }
                    ]
                }
            ) {
                edges {
                node {
                    id
                    email
                }
                }
            }
        }
        $$)
    );

    -- NOT filter nested inside OR which is nested inside AND
    select jsonb_pretty(
        graphql.resolve($$
        {
            accountCollection(
                filter: {
                    AND: [
                        { id: { gt: 0 } }
                        { id: { lt: 4 } }
                        { OR: [{NOT: {email: { eq: "bat@x.com" }}}, {email: { eq: "cat@x.com" }}] }
                    ]
                }
            ) {
                edges {
                node {
                    id
                    email
                }
                }
            }
        }
        $$)
    );

    -- update by compound filters
    select graphql.resolve($$
        mutation {
            updateAccountCollection(
                set: {
                    email: "new@email.com"
                }
                filter: {
                    OR: [
                        { id: { eq: 3 } }
                        { id: { eq: 5 } }
                        { AND: [{ id: { eq: 1 } }, { email: { eq: "aardvark@x.com" } }] }
                    ]
                }
                atMost: 5
            ) {
                records { id, email }
            }
        }
        $$
    );
    rollback to savepoint a;

    -- delete by compound filters
    select graphql.resolve($$
        mutation {
            deleteFromAccountCollection(
                filter: {
                    OR: [
                        { id: { eq: 3 } }
                        { id: { eq: 5 } }
                        { id: { eq: 1 }, email: { eq: "aardvark@x.com" } }
                    ]
                }
                atMost: 5
            ) {
                records { id }
            }
        }
        $$
    );
    rollback to savepoint a;

    -- columns named AND, OR and NOT, all compound filters will be disabled
    comment on schema public is e'@graphql({"inflect_names": false})';
    create table clashes(
        "AND" serial primary key,
        "OR" varchar(255) not null,
        "NOT" plan not null
    );

    insert into public.clashes("OR", "NOT")
    values
        ('aardvark@x.com', 'free'),
        ('bat@x.com', 'pro'),
        ('cat@x.com', 'enterprise'),
        ('dog@x.com', 'free'),
        ('elephant@x.com', 'pro');

    select jsonb_pretty(
        graphql.resolve($$
        {
            clashesCollection(filter: {AND: {eq: 1}, OR: {eq: "aardvark@x.com"}, NOT: {eq: "free"}}) {
                edges {
                    node {
                        AND
                        OR
                        NOT
                    }
                }
            }
        }
        $$)
    );
    rollback to savepoint a;

    -- column named `AND`. AND compound filter will be disabled, others should work
    comment on schema public is e'@graphql({"inflect_names": false})';
    create table clashes(
        "AND" serial primary key,
        email varchar(255) not null,
        plan plan not null
    );

    insert into public.clashes(email, plan)
    values
        ('aardvark@x.com', 'free'),
        ('bat@x.com', 'pro'),
        ('cat@x.com', 'enterprise'),
        ('dog@x.com', 'free'),
        ('elephant@x.com', 'pro');

    select jsonb_pretty(
        graphql.resolve($$
        {
            clashesCollection(
                filter: {
                    OR: [
                        { AND: { eq: 3 } }
                        { AND: { eq: 5 } }
                        { AND: { eq: 2 }, NOT: { email: { eq: "aardvark@x.com" }} }
                    ]
                }
            ) {
                edges {
                    node {
                        AND
                        email
                        plan
                    }
                }
            }
        }
        $$)
    );
    rollback to savepoint a;

    -- column named `OR`. OR compound filter will be disabled, others should work
    comment on schema public is e'@graphql({"inflect_names": false})';
    create table clashes(
        id serial primary key,
        "OR" varchar(255) not null,
        plan plan not null
    );

    insert into public.clashes("OR", plan)
    values
        ('aardvark@x.com', 'free'),
        ('bat@x.com', 'pro'),
        ('cat@x.com', 'enterprise'),
        ('dog@x.com', 'free'),
        ('elephant@x.com', 'pro');

    select jsonb_pretty(
        graphql.resolve($$
        {
            clashesCollection(
                filter: {
                    AND: [ {NOT: {id: { eq: 2 }}}, { OR: { neq: "aardvark@x.com" }}]
                }
            ) {
                edges {
                    node {
                        id
                        OR
                        plan
                    }
                }
            }
        }
        $$)
    );
    rollback to savepoint a;

    -- column named `NOT`. NOT compound filter will be disabled, others should work
    comment on schema public is e'@graphql({"inflect_names": false})';
    create table clashes(
        id serial primary key,
        email varchar(255) not null,
        "NOT" plan not null
    );

    insert into public.clashes(email, "NOT")
    values
        ('aardvark@x.com', 'free'),
        ('bat@x.com', 'pro'),
        ('cat@x.com', 'enterprise'),
        ('dog@x.com', 'free'),
        ('elephant@x.com', 'pro');

    select jsonb_pretty(
        graphql.resolve($$
        {
            clashesCollection(
                filter: {
                    OR: [
                        {id: {eq: 1}}
                        {NOT: {eq: "pro"}, AND: [{id: {eq: 2}}, {email: {eq: "bat@x.com"}}]}
                    ]
                }
            ) {
                edges {
                    node {
                        id
                        email
                        NOT
                    }
                }
            }
        }
        $$)
    );
    rollback to savepoint a;

rollback;
