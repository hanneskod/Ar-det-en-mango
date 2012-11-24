package {

	public class RandomArray {
	
		private var objects:Array = new Array();
		//private var map:Array = new Array();
		
		public function add(obj:Object, weight:int):void {
			this.objects.push(new Array(obj, weight));
			/*for (var i:int=0; i<weight; i++) {
				this.map.push(this.objects.lenght-1);
			}*/
		}
		
		public function get(index:int):Object {
			return objects[index][0];
		}
		
		public function getRandom():Object {
			//returnerar ett obj, slumpmässigt, beroende på viktning
			var map:Array = this.getMap();
			var index:int = Math.floor(Math.random() * map.length);
			return this.objects[map[index]][0];
		}
		
		private function getMap():Array {
			//skapar en array med lika många referenser till varje obj som deras weight
			var map:Array = new Array();
			for (var i:int=0; i<this.objects.length; i++) {
				for (var ii:int=0; ii<this.objects[i][1]; ii++) {
					map.push(i);
				}
			}
			return map;
		}
	
	}

}