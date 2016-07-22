# Semantic-Scaffold-for-Neo4j
Using Semantic-UI and custom templates to provide a sane scaffold generator for Rails 4/5 with Neo4j


Use with `rails new MyApp -m <path to the cloned repository>/Semantic-Scaffold-for-Neo4j/neo4jrb.io.rb -O`

### Once MyApp is created:

- change config/neo4j.yml to match your setup
- use the scaffold generators to add models, such as `rails generate scaffold Artefact name:string content:text author:references` and `rails generate scaffold Author name:string artefacts:references`.

### Once the scaffold is generated:
- change the relationship in the model definition to match your purposes
- change the `_form.html.erb` as indicated with the line ```# Edit the Class.all.sort to the Class name of the connected node (such as `GeospatialNode.all.sort`)```
  - (In this case you would edit `MyApp/app/views/artefacts/_form.html.erb` and change `Class.all.sort` to `Author.all.sort`)

You should now be able to run `rails s` and use a functional app with Semantic-UI
