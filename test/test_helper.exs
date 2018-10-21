Application.load(:hive) #(1)

for app <- Application.spec(:hive,:applications) do #(2)
  Application.ensure_all_started(app)
end


ExUnit.start()
