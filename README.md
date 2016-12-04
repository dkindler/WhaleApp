# WhaleApp
The following iPhone app is part of my application to join the Whale team

### Implementation Considerations
  1. Video Merging
     * Instead of merging videos into one main vide after each is recorded, I decided to save each video separately and merge them all at the end once the user has gone to the `post`, or `watch` page. My reasoning was that in practice, a user may want to delete a video segment. If we were to merge the video segment to the main video, and then have a user decide that they do not want to keep that segment, we must now trim the main video. By waiting until the end when the user knows which videos they want, we avoid this situation.
  2. Indicating video is of minimum length
     * I did not want the only indicator for informing the user that his video is long enough to post to be enabling the `Next` button. So, I created a progress bar at the top which initially has a white progress tint. Once the video is greater or equal to six seconds, the progress tint turns into a blue color.
  3. Indicating video is recording
     * I wanted a way to indicate to the user that video was currently being recorded. I came up with a simple animation that turns the grey, boxy record button into a smaller blue circle once video recording has commenced.


### Implementation Issues
  1. Video Deletion
     * I did not handle deleting any video files recorded on the app. To delete the actual video files from the device, one must actually delete the app
  2. Video Merging
     * I spent a _long long_ time trying to fix an issue I had with video merging. Whenever I merged the videos together, they would come out in landscape orientation. After a while digging around in Apple's docs, I found out that by default all `AVMutableComposition` merge videos in landscape. I fixed this issue with the following line: `            compTrack.preferredTransform = CGAffineTransform(a: 0, b: 1, c: 1, d: 0, tx: 0, ty: 0)`
  3. Progress Bar Segment Indicator
     * After getting stuck on the landscape video merging issue for a bit, I did not have enough time to implement segments for different videos in the progress bar.
