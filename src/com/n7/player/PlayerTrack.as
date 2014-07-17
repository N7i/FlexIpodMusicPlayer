
package com.n7.player{
	
	public class PlayerTrack{
		public var title:String = "";
		public var artist:String = "";
		public var album:String = "";
		public var totalTime:String = "0:00";
		public var file:String="";
		public var trackNumber:Number=0;
		private var _totalSeconds:Number = 0;
		
			 
		public function PlayerTrack(title:String=null,artist:String=null,album:String = null,file:String = null,trackNumber:Number = 0,totalSeconds:Number = 0):void{
			this.title = title;
			this.artist = artist;
			this.album = album;
			this.totalSeconds = totalSeconds;
			this.file = file;
			this.trackNumber = trackNumber;
			this.totalTime = ":"+totalSeconds;
		}
		
		
		public function set totalSeconds(seconds:Number):void{
			_totalSeconds=seconds;
			var min:Number = (_totalSeconds - (_totalSeconds%60))/60;
			var sec:Number = _totalSeconds%60;
			this.totalTime = min + ':';
			if(sec<10){
				this.totalTime += "0";
			}
			this.totalTime += sec;
		}
		public function get totalSeconds():Number{
			return _totalSeconds;	
		}
		
		public function toString():String{
			return this.trackNumber + ". " + this.title + " - " + this.artist;
		}
		
		public function copy():PlayerTrack{
			var copy:PlayerTrack = new PlayerTrack();
			copy.album = this.album;
			copy.artist = this.artist;
			copy.totalTime = this.totalTime;
			copy.totalSeconds = this.totalSeconds;
			copy.file = this.file;
			copy.title = this.title;
			copy.trackNumber = this.trackNumber;
			return copy;
		}
	}
}