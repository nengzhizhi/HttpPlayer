package cc.hl.model.video.base{
	
	/**
	 * 用户点播时记录子码流信息
	**/

	public class PartVideoInfo{

		public var index:int;
		public var url:String;
		public var duration:Number;


		public function PartVideoInfo(arg1:int, arg2:String, arg3:Number){
			this.index = arg1;
			this.url = arg2;
			this.duration = arg3;
		}
	}
}