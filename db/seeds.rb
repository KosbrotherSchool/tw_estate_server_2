# encoding: UTF-8


newType = GroundType.new
newType.name = "房地(土地+建物)"
newType.save

newType = GroundType.new
newType.name = "房地(土地+建物)+車位"
newType.save

newType = GroundType.new
newType.name = "土地"
newType.save

newType = GroundType.new
newType.name = "建物"
newType.save

newType = GroundType.new
newType.name = "車位"
newType.save

newBuildingType = BuildingType.new
newBuildingType.name = "公寓(5樓含以下無電梯)"
newBuildingType.save

newBuildingType = BuildingType.new
newBuildingType.name = "透天厝"
newBuildingType.save

newBuildingType = BuildingType.new
newBuildingType.name = "店面（店舖)"
newBuildingType.save

newBuildingType = BuildingType.new
newBuildingType.name = "辦公商業大樓"
newBuildingType.save

newBuildingType = BuildingType.new
newBuildingType.name = "住宅大樓(11層含以上有電梯)"
newBuildingType.save

newBuildingType = BuildingType.new
newBuildingType.name = "華廈(10層含以下有電梯)"
newBuildingType.save

newBuildingType = BuildingType.new
newBuildingType.name = "套房(1房(1廳)1衛)"
newBuildingType.save

newBuildingType = BuildingType.new
newBuildingType.name = "工廠"
newBuildingType.save

newBuildingType = BuildingType.new
newBuildingType.name = "廠辦"
newBuildingType.save

newBuildingType = BuildingType.new
newBuildingType.name = "農舍"
newBuildingType.save

newBuildingType = BuildingType.new
newBuildingType.name = "倉庫"
newBuildingType.save

newBuildingType = BuildingType.new
newBuildingType.name = "其他"
newBuildingType.save