package cc.hl.model.video.part {
	
	import flash.net.*;
	import util.*;
	
	public class MP4PartNetStream extends PartNetStream{

		public function MP4PartNetStream(connection:NetConnection){
			super(connection);
		}

		override public function get time():Number{
			if(!isNaN(this.realStart)){
				return super.time + this.realStart;
			}
			return this.expectStartTime;
		}

		override public function seek(seekTime:Number):void{
			var _local1:Number = seekTime - this.realStart;
			var _local2:Number = this.streamSeconds;

			_local1 = _local1 < _local2 ? _local1 : _local2;
			if (Math.abs((_local2 - super.time)) > 1){
				super.seek(_local1);
			}
		}

		override protected function checkBufferWithMeta():Number{
			var _local1:int = Util.bsearch(this._meta.keyframes.filepositions, this.bytesLoaded);
			return this._meta.keyframes.times[(_local1 - 1)] + this.realStart;
		}

		override public function searchByte(bytes:Number):int{
			return (0);
		}

		override protected function onMetaData(obj:Object):void{
			var _local1:Object;
			var _local2:Object;

			this._meta = obj;

			if(obj.seekpoints){
				_local1 = {
					times:[],
					filepositions:[]
				}

				for each (_local2 in obj.seekpoints){
					_local1.times.push(_local2.time);
					_local1.filepositions.push(_local2.offset);
				}
				obj.keyframes = _local1;
			}
			
			this.realStart = this.expectStartTime;
			if(obj.duration){
				this.realStart = this._partVideoInfo.duration - obj.duration;
				if(this.realStart < 0){
					this.realStart = 0;
				}
			}
		}

	}
}