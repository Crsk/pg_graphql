begin;

    create table author(
        id int primary key,
        a int,
        aa int,
        aaa int,
        aaaa int,
        aaaaa int,
        aaaaaa int,
        aaaaaaa int,
        aaaaaaaa int
    );

    create table book(
        id int primary key,
        author_id int references author(id),
        a int,
        aa int,
        aaa int,
        aaaa int,
        aaaaa int,
        aaaaaa int,
        aaaaaaa int,
        aaaaaaaa int
    );


    select jsonb_pretty(
        graphql.resolve($$
    {
      bookCollection {
        edges {
          node {
            id
            author {
              id
              bookCollection {
                edges {
                  node {
                    id
                    author {
                      id
                      bookCollection {
                        edges {
                          node {
                            id
                            author {
                              id
                              bookCollection {
                                edges {
                                  node {
                                    id
                                    author {
                                      id
                                      bookCollection {
                                        edges {
                                          node {
                                            id
                                            author {
                                              id
                                              bookCollection {
                                                edges {
                                                  node {
                                                    id
                                                    author {
                                                      id
                                                      bookCollection {
                                                        edges {
                                                          node {
                                                            id
                                                            author {
                                                              id
                                                              bookCollection {
                                                                edges {
                                                                  node {
                                                                    id
                                                                    author {
                                                                      id
                                                                      bookCollection {
                                                                        edges {
                                                                          node {
                                                                            id
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
        $$)
    );


rollback;
