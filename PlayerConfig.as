package {
	public class PlayerConfig{
		private static var _instance:PlayerConfig;

		public var max_use_memory_level:int = 0;

		public function PlayerConfig():void{
			if(_instance != null){
				throw (new Error("请使用getInstance()获取实例")); 
			}
		}

		public static function getInstance():PlayerConfig {
			if(_instance == null){
				_instance = new PlayerConfig();
				_instance.init();
			}
			return _instance;
		}

		private function init():void{
			
		}
	}
}