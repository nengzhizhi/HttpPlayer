package
{
	import flash.display.*;

	public class GlobalData extends Object
	{
		public function GlobalData() {
			super();
		}

		public static var VIDEO_LAYER:Sprite;
		public static var CONTROL_BAR_LAYER:Sprite;
		public static var DANMU_LAYER:Sprite;
		public static var CAMERA_LAYER:Sprite;
		public static var STAGE:Stage;

		public static var root:HttpPlayer;

		public static const MAX_USE_MEMORY_ARRAY:Array = [
														104857600,//100M
														209715200,//200M, 
														0x19000000, 
														int.MAX_VALUE//4G
													];//视频缓存池能够使用的最大内存

		public static var offsetUpHeight:int = 20;
		public static var offsetDownHeight:int = 0;													
		public static var textAlphaValue:Number = 0.85;
		public static var textSizeValue:Number = 14;

	}
}