db.users.insertOne({
    username: "timur",
    email: "timur@example.com",
    country: "Russia",
    subsctibe: {
        plan: "free",
        month: 100,
    },
});
db.users.insertOne({
    username: "amir",
    email: "amir@example.com",
    country: "Russia",
    subsctibe: {
        plan: "free",
        month: 100,
    },
    isArtis: true,
});
db.tracks.insertOne({
    title: "Hello bandits",
    description: "Hello bandits is a good song",
    durationMs: 180000,
    artist: ObjectId("69b1c3541c055965b0bb0b29"),
    album: "Album 1",
    genre: "Hip-Hop",
    createdAt: new Date(),
});
db.users.find({ country: "Russia" });
db.tracks.findOne({ genre: "Hip-Hop" }, { title: 1, album: 1, _id: 0 });
db.tracks.aggregate([
    { $match: { genre: "Hip-Hop" } },
    {
        $group: {
            _id: "$album",
            totalDuration: { $sum: "$durationMs" },
            trackCount: { $count: {} },
        },
    },
    { $sort: { totalDuration: -1 } },
]);
db.users.updateOne(
    { username: "timur" },
    { $set: { "subsctibe.plan": "premium", "subsctibe.month": 1000 } }
);
db.tracks.updateMany(
    { genre: "Hip-Hop" },
    { $set: { genre: "Rap" }, $currentDate: { updatedAt: true } }
);
db.users.deleteOne({ username: "amir" });
db.tracks.deleteMany({ durationMs: { $lt: 60000 } });