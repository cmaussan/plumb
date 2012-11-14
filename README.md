plumb
=====

A Dancer Backend/Dashboard for Graphite

This is a WIP, help is welcome :)

dashboard.yaml exemple one:

    "dashboard1":
      group: group1
      stations:
        - station1
      graphs:
        - load

dashboard.yaml exemple two:

    "dashboard1":
      group: group1
      stations:
        - station1
        - station2
      graphs:
        - { load: [ "station1" ] }
        - { load: [ "station2" ] }

dashboard.yaml exemple three:

    "dashboard1":
      group: group1
      stations:
        - station1
        - station2
      graphs:
        - { load: "foreach" }

graph/load.yaml exemple:

    # Load graph global
    pattern: monitoring.nagios.__station__
    
    global:
      fontSize: 10
      title: "Load (__station__)"
      targets:
      until: 
      vtitle:
      fontName: "DroidSans"
      lineMode: 
      lineWidth: 1
      bgcolor: "000000"
      fgcolor: "CCCCCC"
      majorGridLineColor: "ADADAD"
      minorGridLineColor: "E5E5E5"
      yMin:
      yMax:
      areaMode: 
      hideLegend:

    targets:
      -
        sonde: "load1"
        functions: 
          - sumSeries
          - { color: "yellow" }
          - { alias: "load 1" }
      -      
        sonde: "load5"
        functions: 
          - sumSeries
          - { color: "orange" }
          - { alias: "load 5" }
      - 
        sonde: "load15"
        functions: 
          - sumSeries
          - { color: "red" }
          - { alias: "load 15" }

